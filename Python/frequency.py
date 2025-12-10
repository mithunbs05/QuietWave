import pandas as pd
import joblib
import firebase_admin
from firebase_admin import credentials, db
from statistics import mode
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle
import time

cred = credentials.Certificate('your json file path')
firebase_admin.initialize_app(cred, {'databaseURL': 'enter your credentials here'})

model = joblib.load('random_forest_model1.pkl')
logistic_regression_model = joblib.load('logistic_regression_model.pkl')
firebase_ref = db.reference('path to parameters in firebase')
frequency_predictions_dict = {}
stage_predictions_dict = {}


def generate_medical_report(patient_data, current_state):
    filename = "medical_report.pdf"
    doc = SimpleDocTemplate(filename, pagesize=letter)

    # Create a list of data to be included in the PDF
    data = [['Parameter', 'Value'],
            ['Average Pulse', round(patient_data['pulse'], 2)],
            ['Average Frequency', round(patient_data['frequency'], 2)],
            ['Average Stress', round(patient_data['stress'], 2)],
            ['Current State', current_state],
            ['Future State', current_state]]

    table = Table(data)
    style = TableStyle([('BACKGROUND', (0, 0), (-1, 0), colors.grey),
                        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
                        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
                        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
                        ('GRID', (0, 0), (-1, -1), 1, colors.black)])

    table.setStyle(style)
    doc.build([table])
    
while True:
    try:
        subfolders = firebase_ref.get()

        if subfolders:
            for date, time_data in subfolders.items():
                if date not in frequency_predictions_dict:
                    frequency_predictions_dict[date] = {'values': [], 'uploaded': False}
                    
                if date not in stage_predictions_dict:
                    stage_predictions_dict[date] = {'values': [], 'uploaded': False}
                    
                for timestamp, data in time_data.items():
                    try:
                        pulse, frequency, category, stress = map(str, data.split('|'))
                    except ValueError:
                        continue
                    if frequency=="Abnormal":
                        frequency= 1
                    else:
                        frequency= 0
                    pulse = int(pulse)
                    category = int(category)
                    stress = float(stress)
                    input_data = pd.DataFrame({'pulse': [pulse], 'category': [frequency]})
                    
                    lr_input_data = pd.DataFrame({'pulse': [pulse], 'stress': [stress]})
                    lr_tinnitus_prediction = logistic_regression_model.predict(lr_input_data)
                    if lr_tinnitus_prediction[0] == "normal":
                        lr_tinnitus_prediction[0] = "Abnormal"

                    frequency_prediction = model.predict(input_data)

                    frequency_predictions_dict[date]['values'].append(frequency_prediction[0])
                    stage_predictions_dict[date]['values'].append(lr_tinnitus_prediction[0])

                    if (
                        len(frequency_predictions_dict[date]['values']) == 10
                        and not frequency_predictions_dict[date]['uploaded']
                        ):
                        average_frequency = int(round(sum(frequency_predictions_dict[date]['values']) / 10.0, 2))
                        average_frequency = str(average_frequency)
                        data_values_tuples = [tuple(d['values']) for d in stage_predictions_dict.values()]
                            
                        if not stage_predictions_dict[date]['uploaded']:
                                
                            modes = mode(data_values_tuples)
                                
                            timestamp_key = f'path to upload predictions/{date}'
                            stage_key = f'path to upload predictions/{timestamp}'
                            db.reference(timestamp_key).set(average_frequency)
                            db.reference(stage_key).set(modes[0])

                            frequency_predictions_dict[date]['uploaded'] = True
                            stage_predictions_dict[date]['uploaded'] = True

                            frequency_predictions_dict[date]['values'] = []
                            stage_predictions_dict[date]['values'] = []
                        average_frequency = int(average_frequency)
                        average_pulse = round(sum([int(data.split("|")[0]) for data in time_data.values()]) / 10.0, 2)
                        average_stress = round(sum(([float(data.split("|")[3]) for data in time_data.values()])) / 10.0, 2)
                        average_patient_data = {'pulse': average_pulse, 'frequency': average_frequency, 'stress': average_stress}

                        current_state = modes[0]

                        generate_medical_report(average_patient_data, current_state)
    except Exception as e:
        print(f"An error occurred: {e}")
        import traceback
        traceback.print_exc()

    time.sleep(5)