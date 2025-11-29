import pandas as pd
import streamlit as st
import requests
import plotly.express as px
import logging
from logging.handlers import RotatingFileHandler

# ==========================================================
#  LOGGING
# ==========================================================
log = logging.getLogger("dashboard")
log.setLevel(logging.INFO)

# Filhandler
fh = logging.FileHandler("/var/log/dashboard/dashboard.log")
fh.setLevel(logging.INFO)

# Terminalhandler
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)

# Format
fmt = logging.Formatter("%(asctime)s [%(levelname)s] %(message)s")
fh.setFormatter(fmt)
ch.setFormatter(fmt)

log.addHandler(fh)
log.addHandler(ch)

log.info("Dashboard starter ...")


# ==========================================================
#  KONSTANTER
# ==========================================================
API_URL = "http://fastapi-api:8000/maalinger?limit=500"

st.title("📡 Ventilationsdata – LIVE Dashboard (Model A v4)")
st.write("Live data hentet fra QuestDB via FastAPI")


# ==========================================================
#  LOAD DATA
# ==========================================================
def load():
    log.info(f"Henter data fra API: {API_URL}")

    try:
        r = requests.get(API_URL)
        r.raise_for_status()
        df = pd.DataFrame(r.json())
    except Exception as e:
        log.error(f"Fejl ved API-kald: {e}")
        st.error("❗ Fejl: Dashboardet kunne ikke hente data fra API.")
        return pd.DataFrame()

    df["timestamp"] = pd.to_datetime(df["timestamp"])
    log.info(f"Indlæst {len(df)} målinger")

    return df


df = load()

if df.empty:
    st.stop()

# Brug kun de seneste 200 datapunkter
df = df.tail(200)


# ==========================================================
#  PLOT FUNKTION
# ==========================================================
def plot_col(name, label, yrange, alarm=None, alarm_type="high"):

    log.info(f"Plotter graf: {name}, alarm={alarm}, type={alarm_type}")

    fig = px.line(df, x="timestamp", y=name, title=label)
    fig.update_traces(mode="lines", line=dict(width=2))
    fig.update_yaxes(range=yrange, autorange=False)

    if alarm is not None:
        if alarm_type == "high":
            overs = df[df[name] > alarm]
        else:
            overs = df[df[name] < alarm]

        if len(overs) > 0:
            log.info(f"Alarm fundet for {name}: {len(overs)} punkter")

            fig.add_scatter(
                x=overs["timestamp"],
                y=overs[name],
                mode="markers",
                marker=dict(color="red", size=10),
                name="Alarm"
            )

        fig.add_hline(
            y=alarm,
            line_dash="dash",
            line_color="red",
            annotation_text="Alarm",
            annotation_position="top left",
            annotation_font_color="red"
        )

    st.plotly_chart(fig, use_container_width=True)


# ==========================================================
#  KPI – seneste måling
# ==========================================================
st.subheader("🔍 Seneste måling")
latest = df.iloc[-1]

col1, col2, col3, col4, col5 = st.columns(5)
col1.metric("🌡 Udendørs temp", f"{latest['udendoers_temp']:.1f} °C")
col2.metric("🏠 Rum temp", f"{latest['rum_temp']:.1f} °C")
col3.metric("➡️ Tilluft temp", f"{latest['tilluft_temp']:.1f} °C")
col4.metric("⚡ Effektforbrug", f"{latest['effektforbrug']:.1f} W")
col5.metric("📈 Virkningsgrad", f"{latest['virkningsgrad']:.1f} %")


# ==========================================================
#  SAMLET GRAF
# ==========================================================
st.header("📈 Samlet graf – alle målinger")

log.info("Plotter samlet graf")

st.line_chart(
    df.set_index("timestamp")[[       
        "udendoers_temp",
        "rum_temp",
        "tilluft_temp",
        "effektforbrug",
        "virkningsgrad"
    ]]
)


# ==========================================================
#  INDIVIDUELLE GRAFER
# ==========================================================
st.header("📊 Individuelle grafer")

plot_col("udendoers_temp", "Udendørs temperatur (°C)", yrange=[0, 15], alarm=12, alarm_type="high")
plot_col("rum_temp", "Rum temperatur (°C)", yrange=[18, 23], alarm=22, alarm_type="high")
plot_col("tilluft_temp", "Tilluft temperatur (°C)", yrange=[8, 15], alarm=14, alarm_type="high")
plot_col("effektforbrug", "Effektforbrug (W)", yrange=[150, 250], alarm=230, alarm_type="high")
plot_col("virkningsgrad", "Virkningsgrad (%)", yrange=[70, 80], alarm=76.2, alarm_type="low")


# ==========================================================
#  SENESTE 10 RÅDATA
# ==========================================================
st.header("📄 Seneste 10 rådata")

raw10 = df.tail(10).copy()
raw10["timestamp"] = raw10["timestamp"].dt.strftime("%Y-%m-%d %H:%M:%S")

log.info("Viser seneste 10 rådata")

st.dataframe(raw10, use_container_width=True)


# ==========================================================
#  ALARMSTATUS (seneste 50 målinger)
# ==========================================================
st.header("🚨 Alarmstatus")

alarms = []
hist50 = df.tail(50)

if (hist50["udendoers_temp"] > 12).any():
    alarms.append("Udendørs temp over 12°C")
if (hist50["rum_temp"] > 22).any():
    alarms.append("Rumtemp over 22°C")
if (hist50["tilluft_temp"] > 14).any():
    alarms.append("Tilluft-temp over 14°C")
if (hist50["effektforbrug"] > 230).any():
    alarms.append("Effektforbruget er meget højt")
if (hist50["virkningsgrad"] < 76.2).any():
    alarms.append("Virkningsgrad er under grænsen 76.2")

log.info(f"Alarmstatus: {alarms}" if alarms else "Ingen alarmer")

if len(alarms) == 0:
    st.success("✅ Ingen alarmer — alle værdier er inden for grænserne.")
else:
    for alarm in alarms:
        st.error(f"❗ {alarm}")


# ==========================================================
#  CSV DOWNLOAD
# ==========================================================
st.header("⬇️ Download CSV")

csv = df.to_csv(index=False).encode("utf-8")

log.info("CSV-download genereret")

st.download_button(
    label="Download data som CSV",
    data=csv,
    file_name="ventilationsdata.csv",
    mime="text/csv",
)


# ==========================================================
#  ALARMHISTORIK (seneste 50 målinger)
# ==========================================================
st.header("📊 Alarmhistorik – sidste 50 målinger")

alarm_counts = {
    "udendoers_temp": int((hist50["udendoers_temp"] > 12).sum()),
    "rum_temp": int((hist50["rum_temp"] > 22).sum()),
    "tilluft_temp": int((hist50["tilluft_temp"] > 14).sum()),
    "effektforbrug": int((hist50["effektforbrug"] > 230).sum()),
    "virkningsgrad": int((hist50["virkningsgrad"] < 76.2).sum()),
}

log.info(f"Alarmhistorik: {alarm_counts}")

st.write(alarm_counts)

