import streamlit as st
import pandas as pd
import sqlite3
from streamlit_autorefresh import st_autorefresh

DB_PATH = "/home/victor/tempprojekt/sensordata.db"

st.set_page_config(page_title="Ventilationsdata Dashboard", layout="wide")
st.title("🌬️ Ventilationsdata – Temperatur og Fugt")

# Auto-refresh
st.sidebar.write("⚙️ Indstillinger")
autorefresh = st.sidebar.checkbox("Auto-opdater hver 30 sek.", value=True)
if autorefresh:
    st_autorefresh(interval=30 * 1000, key="refresh")

@st.cache_data(ttl=5)
def load_data():
    conn = sqlite3.connect(DB_PATH)
    df = pd.read_sql_query(
        "SELECT timestamp, temperatur, fugt, device FROM målinger ORDER BY rowid DESC LIMIT 500",
        conn
    )
    conn.close()
    return df

data = load_data()

if data.empty:
    st.warning("Ingen data i databasen.")
    st.stop()

seneste = data.iloc[0]
st.metric(
    label=f"Seneste Temperatur (device: {seneste['device']})",
    value=f"{seneste['temperatur']} °C",
    help=f"Fugt: {seneste['fugt']}%\nTid: {seneste['timestamp']}"
)

st.subheader("📈 Temperatur over tid")
st.line_chart(data, x="timestamp", y="temperatur")

st.subheader("💧 Fugt over tid")
st.line_chart(data, x="timestamp", y="fugt")

st.subheader("📋 Rå data")
st.dataframe(data)

csv = data.to_csv(index=False).encode("utf-8")
st.download_button(
    label="📥 Download CSV",
    data=csv,
    file_name="ventilationsdata.csv",
    mime="text/csv"
)
