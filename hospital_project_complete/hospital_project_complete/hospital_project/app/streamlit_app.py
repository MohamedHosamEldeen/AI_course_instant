import streamlit as st
import pandas as pd
from pathlib import Path
BASE=Path(__file__).resolve().parents[1]; DATA=BASE/'data'/'cleaned'
st.set_page_config(page_title='Hospital Management & Analytics',layout='wide')
@st.cache_data
def load(n): return pd.read_csv(DATA/f'{n}.csv')
st.sidebar.title('Hospital System')
page=st.sidebar.radio('Page',['Dashboard','Patients','Doctors','Nurses','Employees','Attendance','Appointments','Admissions','Medical Records','Pharmacy','Billing','Payments','Analytics'])
if page=='Dashboard':
    p,e,a,i=load('patients'),load('employees'),load('appointments'),load('invoices')
    c=st.columns(5); c[0].metric('Patients',len(p)); c[1].metric('Employees',len(e)); c[2].metric('Doctors',(e.JobTitle=='Doctor').sum()); c[3].metric('Appointments',len(a)); c[4].metric('Revenue',f'{i.TotalAmount.sum():,.0f}')
    st.bar_chart(a.Status.value_counts()); st.bar_chart(e.JobTitle.value_counts())
elif page=='Patients': st.dataframe(load('patients'),use_container_width=True)
elif page=='Doctors': st.dataframe(load('employees').query("JobTitle=='Doctor'"),use_container_width=True)
elif page=='Nurses': st.dataframe(load('employees').query("JobTitle=='Nurse'"),use_container_width=True)
elif page=='Employees': st.dataframe(load('employees'),use_container_width=True)
elif page=='Attendance':
    d=load('attendance'); st.dataframe(d,use_container_width=True); st.bar_chart(d.Status.value_counts())
elif page=='Appointments':
    d=load('appointments'); st.dataframe(d,use_container_width=True); st.bar_chart(d.Status.value_counts())
elif page=='Admissions': st.dataframe(load('admissions'),use_container_width=True)
elif page=='Medical Records': st.dataframe(load('medical_records'),use_container_width=True)
elif page=='Pharmacy':
    d=load('medicines'); d['StockStatus']=d.apply(lambda r:'Low Stock' if r.Quantity<=r.MinimumStock else 'OK',axis=1); st.dataframe(d,use_container_width=True); st.bar_chart(d.StockStatus.value_counts())
elif page=='Billing':
    d=load('invoices'); c=st.columns(3); c[0].metric('Billed',f'{d.TotalAmount.sum():,.0f}'); c[1].metric('Paid',f'{d.PaidAmount.sum():,.0f}'); c[2].metric('Remaining',f'{d.RemainingAmount.sum():,.0f}'); st.dataframe(d,use_container_width=True)
elif page=='Payments':
    d=load('payments'); st.dataframe(d,use_container_width=True); st.bar_chart(d.groupby('PaymentMethod').Amount.sum())
elif page=='Analytics':
    st.title('Analytics'); st.bar_chart(load('appointments').Status.value_counts()); st.bar_chart(load('attendance').Status.value_counts()); st.bar_chart(load('invoices').groupby('Status').TotalAmount.sum())
