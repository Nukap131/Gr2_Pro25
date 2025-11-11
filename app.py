import streamlit as st
import pandas as pd
import sqlite3
from streamlit_autorefresh import st_autorefresh

# --- Basisindstillinger ---
DB_PATH = "/home/victor/tempprojekt/sensordata.db"
st.set_page_config(page_title="Ventilationsdata Dashboard", layout="wide")
st.title("🌬️ Dokumentation af Temperatur- og Luftkvalitetsdata")

# --- Auto-refresh (hver 30 sekunder) ---
st.sidebar.write("⚙️ Indstillinger")
autorefresh = st.sidebar.checkbox("Auto-opdater hvert 30. sekund", value=True)
if autorefresh:
    st_autorefresh(interval=30 * 1000, key="datarefresh")

# --- Funktion til at hente data ---
@st.cache_data(ttl=30)
def load_data():
    conn = sqlite3.connect(DB_PATH)
    df = pd.read_sql_query("SELECT * FROM measurements ORDER BY id DESC LIMIT 200", conn)
    conn.close()
    return df

data = load_data()

if data.empty:
    st.warning("Ingen data fundet i databasen endnu.")
    st.stop()

# --- Filtrering efter device_id ---
device_ids = ["Alle"] + sorted(data["device_id"].unique().tolist())
valgt_device = st.selectbox("Vælg enhed", device_ids)
if valgt_device != "Alle":
    data = data[data["device_id"] == valgt_device]

# --- Seneste måling ---
seneste = data.iloc[0]
st.metric(
    label=f"Seneste måling ({seneste['device_id']})",
    value=f"{seneste['value']} °C",
    help=f"Tidspunkt: {seneste['ts']}"
)

# --- Vis tabel og graf ---
st.subheader("📈 Målinger")
st.dataframe(data)

st.line_chart(data, x="ts", y="value")

# --- Eksporter som CSV ---
csv = data.to_csv(index=False).encode("utf-8")
st.download_button(
    label="📥 Download data som CSV",
    data=csv,
    file_name="ventilationsdata.csv",
    mime="text/csv",
)
