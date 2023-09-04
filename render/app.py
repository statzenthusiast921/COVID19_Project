#Import packages
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import plotly.express as px
import plotly.graph_objs as go
import dash
import dash_core_components as dcc
import dash_html_components as html
import dash_bootstrap_components as dbc
from dash.dependencies import Input, Output
import time
from datetime import date, datetime
import dash_table



from numpy.lib.function_base import median
#import simplejson as json

who_data = pd.read_csv("https://raw.githubusercontent.com/statzenthusiast921/COVID19_Project/main/data/who_data.csv")
pops = pd.read_csv("https://gist.githubusercontent.com/curran/0ac4077c7fc6390f5dd33bf5c06cb5ff/raw/605c54080c7a93a417a3cea93fd52e7550e76500/UN_Population_2019.csv")
pops = pops[['Country','2020']]
pops['2020'] = pops['2020']*1000
who_data.rename(columns={'New_cases': 'New Cases', 'Cumulative_cases': 'Cumulative Cases', 'New_deaths': 'New Deaths','Cumulative_deaths': 'Cumulative Deaths'}, inplace=True)

#world_path = pd.read_csv("https://raw.githubusercontent.com/statzenthusiast921/Personal-Projects/main/COVID19%20Project/custom.geo.json")
# DATA_PATH = "/Users/jonzimmerman/Desktop/Data Projects/COVID19 Project/covid19-heroku/static/"
# world_path = DATA_PATH + 'custom.geo.json'
# with open(world_path) as f:
#     geo_world = json.load(f)

geo_world = pd.read_json('https://raw.githubusercontent.com/statzenthusiast921/COVID19_Project/main/data/custom.geo.json')

    
country_conversion_dict = {
    'Dominican Rep.': "Dominican Republic", 
    'United States': 'United States of America', 
    'Bolivia': 'Bolivia (Plurinational State of)', 
    'Falkland Is.': 'Falkland Islands (Malvinas)', 
    'Venezuela': 'Venezuela (Bolivarian Republic of)', 
    'N. Cyprus': 'Cyprus', 
    'Brunei': 'Brunei Darussalam', 
    'Iran': 'Iran (Islamic Republic of)', 
    'Korea': 'Republic of Korea', 
    'Palestine': 'occupied Palestinian territory, including east Jerusalem', 
    'Lao PDR': "Lao People's Democratic Republic", 
    #'Taiwan', 
    'Vietnam': 'Viet Nam', 
    'Dem. Rep. Korea': "Democratic People's Republic of Korea", 
    'Syria': 'Syrian Arab Republic', 
    "Côte d'Ivoire": 'Côte d’Ivoire', 
    'Central African Rep.': 'Central African Republic', 
    'Dem. Rep. Congo': 'Democratic Republic of the Congo', 
    'Eq. Guinea': 'Equatorial Guinea', 
    #'W. Sahara', 
    'S. Sudan': 'South Sudan', 
    #'Somaliland', 
    #'Swaziland', 
    'Tanzania': 'United Republic of Tanzania', 
    'Czech Rep.': 'Czechia', 
    'United Kingdom': 'The United Kingdom', 
    'Bosnia and Herz.': 'Bosnia and Herzegovina', 
    'Kosovo': 'Kosovo[1]', 
    'Russia': 'Russian Federation', 
    'Moldova': 'Republic of Moldova', 
    'Macedonia': 'North Macedonia', 
    'Solomon Is.': 'Solomon Islands'
    
}



#Instanciating necessary lists
found = []
missing = []
countries_geo = []

#For simpler access, setting "zone" as index in temporary dataframe
tmp = who_data.set_index('Country')

#Looping over custom GeoJSON file
for country in geo_world['features']:
    
    #Country name detection
    country_name = country['properties']['name']
    
    #Eventual replacement with our transition dictionary
    country_name = country_conversion_dict[country_name] if country_name in country_conversion_dict.keys() else country_name
    go_on = country_name in tmp.index
    
    
    #If country is in original dataset or transition dictionary
    if go_on:
        
        #Adding country to our "Matched/Found" countries list
        found.append(country_name)
        
        #Getting information from both GeoJSON file and dataframe
        geometry = country['geometry']
        
        #Adding 'id' information for further match between map and data
        countries_geo.append({
            'type':'Feature',
            'geometry': geometry,
            'id':country_name
        })
        
    #Else, adding the country to the missing countries list
    else:
        missing.append(country_name)
        
#Displaying metrics
print(f'Countries found: {len(found)}')
print(f'Countries not found: {len(missing)}')
geo_world_ok = {'type':'FeatureCollection','features':countries_geo}




#Adjust for Population

#Join pop on who_data
who_data = who_data.merge(pops, on='Country', how='left')
who_data.rename(columns={'2020': 'Population'}, inplace=True)
#Create pop adjusted metrics
who_data['Adj. Cumulative Cases'] = (who_data['Cumulative Cases']/who_data['Population'])*100000
who_data['Adj. Cumulative Deaths'] = (who_data['Cumulative Deaths']/who_data['Population'])*100000

who_data['Adj. New Cases'] = (who_data['New Cases']/who_data['Population'])*100000
who_data['Adj. New Deaths'] = (who_data['New Deaths']/who_data['Population'])*100000


who_data['Adj. Cumulative Cases'] = who_data['Adj. Cumulative Cases'].round(2)
who_data['Adj. Cumulative Deaths'] = who_data['Adj. Cumulative Deaths'].round(2)
who_data['Adj. New Cases'] = who_data['Adj. New Cases'].round(2)
who_data['Adj. New Deaths'] = who_data['Adj. New Deaths'].round(2)



#Create log count column
who_data['count_color_cc'] = who_data['Cumulative Cases'].apply(np.log10)
who_data['count_color_cd'] = who_data['Cumulative Deaths'].apply(np.log10)
who_data['count_color_adj_cc'] = who_data['Adj. Cumulative Cases'].apply(np.log10)
who_data['count_color_adj_cd'] = who_data['Adj. Cumulative Deaths'].apply(np.log10)


#Get the maximum value to cap displayed values
max_log_cc = who_data['count_color_cc'].max()
max_val_cc = int(max_log_cc) + 1
max_log_adj_cc = who_data['count_color_adj_cc'].max()
max_val_adj_cc = int(max_log_adj_cc) + 1

max_log_cd = who_data['count_color_cd'].max()
max_val_cd = int(max_log_cd) + 1
max_log_adj_cd = who_data['count_color_adj_cd'].max()
max_val_adj_cd = int(max_log_adj_cd) + 1


#Prepare the range of the colorbar
values_cc = [i for i in range(max_val_cc)]
ticks_cc = [10**i for i in values_cc]
values_adj_cc = [i for i in range(max_val_adj_cc)]
ticks_adj_cc = [10**i for i in values_adj_cc]

values_cd = [i for i in range(max_val_cd)]
ticks_cd = [10**i for i in values_cd]
values_adj_cd = [i for i in range(max_val_adj_cd)]
ticks_adj_cd = [10**i for i in values_adj_cd]



country_choices=who_data['Country'].unique()
metric_choices=who_data.columns[4:8]
who_data['Date_reported_string'] = who_data['Date_reported'].copy()
slider_options = dict((d_key, d_val) for d_key, d_val in enumerate(sorted(who_data['Date_reported_string'].unique())))



x = np.linspace(min(slider_options.keys()), max(slider_options.keys()), 10,dtype=int)
x = x.round(0)



tabs_styles = {
    'height': '44px'
}
tab_style = {
    'borderBottom': '1px solid #d6d6d6',
    'padding': '6px',
    'fontWeight': 'bold'
}

tab_selected_style = {
    'borderTop': '1px solid #d6d6d6',
    'borderBottom': '1px solid #d6d6d6',
    'backgroundColor': '#119DFF',
    'color': 'white',
    'padding': '6px'
}


table_show = who_data[["Country","Date_reported","Population","New Cases","Cumulative Cases","New Deaths","Cumulative Deaths"]]
table_show['Date Reported'] = table_show['Date_reported']
table_show = table_show.drop(columns=['Date_reported'])
table_show = table_show[['Country', 'Date Reported', 'Population', "New Cases","Cumulative Cases","New Deaths","Cumulative Deaths"]]

app = dash.Dash(__name__,external_stylesheets=[dbc.themes.BOOTSTRAP])
server = app.server
app.layout = html.Div([
    dcc.Tabs([
        dcc.Tab(label='Welcome',value='tab-1',style=tab_style, selected_style=tab_selected_style,
               children=[
                   html.Div([
                       html.H1(dcc.Markdown('''**My Plotly-Dash COVID19 Dashboard**''')),
                       html.Br()
                   ]),
                   
                   html.Div([
                        html.P(dcc.Markdown('''**What is the purpose of this dashboard?**''')),
                   ],style={'text-decoration': 'underline'}),
                   html.Div([
                       html.P("This dashboard describes the global spread and impact of the COVID19 pandemic. The metrics used to quantify these impacts are 'new cases', 'cumulative cases', new deaths', and 'cumulative deaths'."),
                       html.Br()
                   ]),
                   html.Div([
                       html.P(dcc.Markdown('''**What data is being used for this analysis?**''')),
                   ],style={'text-decoration': 'underline'}),
                   
                   html.Div([
                       html.P(["Data on cases and deaths is pulled from a ", html.A("dashboard",href="https://covid19.who.int/table")," created by the World Health Organization (WHO). 2020 Population data is pulled from a publicly available ", html.A("dataset",href="https://github.com/datasets/population")," created by The World Bank."]),
                       html.Br()
                   ]),
                   html.Div([
                       html.P(dcc.Markdown('''**What are the limitations of this data?**''')),
                   ],style={'text-decoration': 'underline'}),
                   html.Div([
                       html.P("The data collected from the WHO is self-reported, therefore, accuracy may differ by country. Further, there are instances of negative case and death counts for several days. These values represent corrections from a previous day.")
                   ])


               ]),
        dcc.Tab(label='All Data',value='tab-2',style=tab_style, selected_style=tab_selected_style,
               children=[
                   dash_table.DataTable(id='table',
                   columns=[{"name": i, "id": i} for i in table_show.columns],
                   style_data_conditional=[{
                       'if': {'row_index': 'odd'},'backgroundColor': 'rgb(248, 248, 248)'}
                   ],
                   style_header={'backgroundColor': 'rgb(230, 230, 230)','fontWeight': 'bold'},
                   filter_action='native',
                   style_data={'width': '150px', 'minWidth': '150px', 'maxWidth': '150px',
                               'overflow': 'hidden',
                               'textOverflow': 'ellipsis'},
                   #style_table={'height': 400},
                   sort_action='native',sort_mode="multi",
                   page_action="native", page_current= 0,page_size= 20,                     
                   data=table_show.to_dict('records'))
                   
                   
               ]),
        
        
        
        
        
        
        
#Tab 1 --> Plot and Cards by Country
        dcc.Tab(label='Country', value='tab-3', style=tab_style, selected_style=tab_selected_style,
                children=[
            html.Div([
                dcc.Dropdown(
                    id='dropdown1',
                    options=[{'label': i, 'value': i} for i in country_choices],
                    value=country_choices[0]
                )
            ],style={'width': '50%',
                     'display': 'inline-block',
                     'text-align': 'center'}
            ),
            html.Div([
                dcc.Dropdown(
                    id='dropdown2',
                    options=[{'label': i, 'value': i} for i in metric_choices],
                    value=metric_choices[0]
                )],style={'width': '50%',
                          'display': 'inline-block',
                          'text-align': 'center'}
            ),
            html.Div([
                dbc.Row(id="card_row")
            ]),
            html.Div([
                dcc.Graph(id='country_plot')
            ])
        ]),
        
#Tab 2 --> Choropleth World Map by Cases/Deaths   

    
        dcc.Tab(label='Spread', value='tab-4', style=tab_style, selected_style=tab_selected_style,
                children=[
                    #Label Row
                    html.Div([
                        html.Label(dcc.Markdown('''**Choose a date: **''')),
                    ],style={'width': '64%', 'display': 'inline-block','text-align': 'center','padding-left':'2%'}
                    ),
                    html.Div([
                        html.Label(dcc.Markdown('''**Choose a metric: **''')),
                    ],style={'text-align': 'center','width': '17%','display': 'inline-block'}
                    ), 
                    html.Div([
                        html.Label(dcc.Markdown('''**Adjust for Population: **''')),
                    ],style={'text-align': 'center','width': '17%','display': 'inline-block'}
                    
                    
                    ),
                    #Slider and Radio Button Controls Row
                    html.Div([
                        dcc.Slider(id='slider',
                                   min = min(slider_options.keys()),
                                   max = max(slider_options.keys()),                                   
                                   value = min(slider_options.keys()),
                                   marks = {i: slider_options[i] for i in range(x[0], x[-1]) if i % 150 == 0}

                                  )
                        
                    ],style={'width': '64%', 'display': 'inline-block','text-align': 'center','padding-left':'2%'}),
                    html.Div([
                        dcc.RadioItems(
                            id='radio1',
                            options=[
                                {'label': ' Cumulative Cases', 'value': 'Cumulative Cases'},
                                {'label': ' Cumulative Deaths', 'value': 'Cumulative Deaths' }
                            ],value='Cumulative Cases',
                            labelStyle={'display': 'block'}
                        )  
                    ],style={'text-align': 'center','width': '17%','display': 'inline-block'}),
                    html.Div([
                        dcc.RadioItems(
                            id='radio2',
                            options=[
                                {'label': ' Yes', 'value': 'Yes'},
                                {'label': ' No', 'value': 'No' }
                            ],value='No',
                            labelStyle={'display': 'block'}
                        ) 
                        
                    ],style={'text-align': 'center','width': '17%','display': 'inline-block'}),
                    html.Div([
                        dbc.Row(id="card_row2"),
                        dcc.Graph(id='choropleth_plot')
                    ])
        ]),
        
#Tab 3 --> Top 10 Countries by Cumulative Cases/Deaths       
        
        dcc.Tab(label="Top 10", value='tab-5', style=tab_style, selected_style=tab_selected_style,
                children=[
                    #Label Row
                    html.Div([
                        html.Label(dcc.Markdown('''**Choose a date: **''')),
                    ],style={'width': '80%','display': 'inline-block','text-align': 'center','padding-left':'1%'}),
                    html.Div([
                        html.Label(dcc.Markdown('''**Adjust for population: **''')),
                    ],style={'width': '20%','display': 'inline-block','text-align': 'center'}
                    ),
                    
                    #Slider and Radio Button Control Row
                    html.Div([
                        dcc.Slider(id='slider2',
                                   min = min(slider_options.keys()),
                                   max = max(slider_options.keys()),                                   
                                   value = max(slider_options.keys()),
                                   marks = {i: slider_options[i] for i in range(x[0], x[-1]) if i % 150 == 0}

                                  )
                        
                    ],style={'width': '80%','display': 'inline-block','text-align': 'center','padding-left':'1%'}),
                    html.Div([
                        dcc.RadioItems(
                            id='radio3',
                            options=[
                                {'label': ' Yes', 'value': 'Yes'},
                                {'label': ' No', 'value': 'No' }
                            ], value='No',
                            labelStyle={'display': 'block'}
                        )  
                        
                    ],style={'width': '20%','display': 'inline-block','text-align': 'center'}),
                    html.Div([
                        dcc.Graph(id="top10cases"),
                        dcc.Graph(id="top10deaths")
                    ])
    
        ]),
#Tab 4 --> Top 10 Countries by New Cases/Deaths over 14 Day Period   
        
        
        dcc.Tab(label="14-Day Trend", value='tab-6', style=tab_style, selected_style=tab_selected_style,
                children=[
                    #Label Row
                    html.Div([
                        html.Label(dcc.Markdown('''**Choose a date: **''')),
                    ],style={'width': '80%','display': 'inline-block','text-align': 'center','padding-left':'1%'}),
                    html.Div([
                        html.Label(dcc.Markdown('''**Adjust for population: **''')),
                    ],style={'width': '20%','display': 'inline-block','text-align': 'center'}
                    ),
                    
                    #Slider and Radio Button Control Row
                    html.Div([
                        dcc.Slider(id='slider3',
                                   min = min(slider_options.keys()),
                                   max = max(slider_options.keys()),                                   
                                   value = max(slider_options.keys()),
                                   marks = {i: slider_options[i] for i in range(x[0], x[-1]) if i % 150 == 0}

                                  )
                        
                    ],style={'width': '80%','display': 'inline-block','text-align': 'center','padding-left':'1%'}),
                    html.Div([
                        dcc.RadioItems(
                            id='radio4',
                            options=[
                                {'label': ' Yes', 'value': 'Yes'},
                                {'label': ' No', 'value': 'No' }
                            ],value='No',
                            labelStyle={'display': 'block'}
                        )
                        
                    ],style={'width': '20%','display': 'inline-block','text-align': 'center'}),
                    html.Div([
                        dcc.Graph(id="figa1"),
                        dcc.Graph(id="figa2")
                    ])
        ])
    ])
])


#Configure Reactibity for Tab Colors
@app.callback(Output('tabs-content-inline', 'children'),
              Input('tabs-styled-with-inline', 'value'))
def render_content(tab):
    if tab == 'tab-1':
        return html.Div([
            html.H3('Tab content 1')
        ])
    elif tab == 'tab-2':
        return html.Div([
            html.H3('Tab content 2')
        ])
    elif tab == 'tab-3':
        return html.Div([
            html.H3('Tab content 3')
        ])
    elif tab == 'tab-4':
        return html.Div([
            html.H3('Tab content 4')
        ])
    elif tab == 'tab-5':
        return html.Div([
            html.H3('Tab content 5')
        ])
    elif tab == 'tab-6':
        return html.Div([
            html.H3('Tab content 6')
        ])



#Configure Reactivity for Tab 1 Cards
@app.callback(
    Output('card_row','children'),
    Input('dropdown1','value')
)

def update_cards(country_select):
    
    new_df = who_data[(who_data.Country==country_select)]
    c_pop = f"{pops[pops.Country==country_select]['2020'].unique()[0]:,.0f}"
    c_totcases = f"{sorted(who_data[who_data['Country']==country_select]['Cumulative Cases'],reverse=True)[0]:,.0f}"
    c_totdeath = f"{sorted(who_data[who_data['Country']==country_select]['Cumulative Deaths'],reverse=True)[0]:,.0f}"
    

    
    card1 = dbc.Card([
        dbc.CardBody([
            html.H4(c_pop, className="card-title"),
            html.P(f"Current Population of {country_select}")
        ])
    ],
    style={'display': 'inline-block',
           'width': '33.3%',
           'text-align': 'center',
           'background-color': 'rgba(37, 150, 190)',
           'color':'white',
           'fontWeight': 'bold',
           'fontSize':20},
    outline=True)
    
    card2 = dbc.Card([
        dbc.CardBody([
            html.H4(c_totcases, className="card-title"),
            html.P(f"Cumulative Cases for {country_select}")
        ])
    ],
    style={'display': 'inline-block',
           'width': '33.3%',
           'text-align': 'center',
           'background-color': 'rgba(37, 150, 190)',
           'color':'white',
           'fontWeight': 'bold',
           'fontSize':20},
    outline=True)
    
    card3 = dbc.Card([
        dbc.CardBody([
            html.H4(c_totdeath, className="card-title"),
            html.P(f"Cumulative Deaths for {country_select}")
        ])
    ],
    style={'display': 'inline-block',
           'width': '33.3%',
           'text-align': 'center',
           'background-color': 'rgba(37, 150, 190)',
           'color':'white',
           'fontWeight': 'bold',
           'fontSize':20},
    outline=True)
    return (card1, card2, card3)  


#Configure Reactivity for Country Plot on Tab 1
@app.callback(
    Output('country_plot','figure'),
    Input('dropdown1','value'),
    Input('dropdown2','value'))

def update_figure(country_select,metric_select):
        new_df = who_data[(who_data.Country==country_select)]
        country_df = pops[pops.Country==country_select]

        fig = px.line(new_df, x="Date_reported", y=metric_select,
                      title=f'<b>{metric_select} of COVID19 for {country_select}</b>',
                      color_discrete_sequence = ["red"],
                      labels=dict(Date_reported="Date")
                     )
        fig.update_traces(mode='markers+lines',marker=dict(color="black",size=3),line=dict(width=2.5))
        fig.update_layout(title={'x':0.5,
                                 'xanchor': 'center',
                                 'yanchor': 'top'})
    
        return fig


#Configure Reactivity for Choropleth Cards on Tab 2
@app.callback(
    Output('card_row2','children'),
    Input('slider','value')
)

def update_cards2(date_select_index):    
    
    
    date_select = slider_options.get(date_select_index, "1100-01-01")
    date_df = who_data[(who_data.Date_reported<=date_select)]
    tot_cases = f"{date_df['New Cases'].sum():,.0f}"
    tot_deaths = f"{date_df['New Deaths'].sum():,.0f}"
    
    card4 = dbc.Card([
        dbc.CardBody([
            html.H4(tot_cases, className="card-title"),
            html.P(f"Cumulative Cases on {date_select}")

        ])
    ],
    style={'display': 'inline-block',
           'width': '50%',
           'text-align': 'center',
           'background-color': 'rgba(37, 150, 190)',
           'color':'white',
           'fontWeight': 'bold',
           'fontSize':20},
    outline=True)
    
    card5 = dbc.Card([
        dbc.CardBody([
            html.H4(tot_deaths, className="card-title"),
            html.P(f"Cumulative Deaths on {date_select}")
        ])
    ],
    style={'display': 'inline-block',
           'width': '50%',
           'text-align': 'center',
           'background-color': 'rgba(37, 150, 190)',
           'color':'white',
           'fontWeight': 'bold',
           'fontSize':20},
    outline=True)
    
    return (card4, card5)

    
#Configure Reactivity for Choropleth Map on Tab 2
@app.callback(
    Output('choropleth_plot','figure'),
    Input('slider','value'),
    Input('radio1','value'),
    Input('radio2','value'))

def update_figure2(date_select_index,radio_select,radio_select2):
    date_select = slider_options.get(date_select_index, "1100-01-01")
    date_df = who_data[(who_data.Date_reported<=date_select)]  
    
    if 'No' in radio_select2:
        
        if 'Cumulative Cases' in radio_select:
            fig_test = px.choropleth_mapbox(date_df,
                                      geojson=geo_world_ok,
                                      locations='Country',
                                      color=date_df['count_color_cc'],
                                      color_continuous_scale='ylorrd',
                                      range_color=(0, date_df['count_color_cc'].max()),
                                      hover_name='Country',
                                      hover_data = {'count_color_cc':False,
                                                    'Country':False,
                                                    'Cumulative Cases':':,'},
                                      mapbox_style = 'open-street-map',
                                      zoom=1,
                                      center={'lat':19,'lon':11},
                                      opacity=0.6)
            fig_test.update_layout(
                margin={'r':0,'t':0,'l':0,'b':0},
                coloraxis_colorbar={
                'title':'<b>Cumulative Cases</b>',
                'tickvals': values_cc,
                'ticktext': ticks_cc})
            return fig_test


        else:
            fig_test = px.choropleth_mapbox(date_df,
                                      geojson=geo_world_ok,
                                      locations='Country',
                                      color=date_df['count_color_cd'],
                                      color_continuous_scale='ylorrd',
                                      range_color=(0, date_df['count_color_cd'].max()),
                                      hover_name='Country',
                                      hover_data = {'count_color_cd':False,
                                                    'Country':False,
                                                    'Cumulative Deaths':':,'},
                                      mapbox_style = 'open-street-map',
                                      zoom=1,
                                      center={'lat':19,'lon':11},
                                      opacity=0.6)

            fig_test.update_layout(
                margin={'r':0,'t':0,'l':0,'b':0},
                coloraxis_colorbar={
                'title':'<b>Cumulative Deaths</b>',
                'tickvals': values_cd,
                'ticktext': ticks_cd})
            return fig_test
        
    else:
        if 'Cumulative Cases' in radio_select:
            fig_test = px.choropleth_mapbox(date_df,
                                      geojson=geo_world_ok,
                                      locations='Country',
                                      color=date_df['count_color_adj_cc'],
                                      color_continuous_scale='ylorrd',
                                      range_color=(0, date_df['count_color_adj_cc'].max()),
                                      hover_name='Country',
                                      hover_data = {'count_color_adj_cc':False,
                                                    'Country':False,
                                                    'Adj. Cumulative Cases':":,"},
                                      mapbox_style = 'open-street-map',
                                      zoom=1,
                                      center={'lat':19,'lon':11},
                                      opacity=0.6)
            fig_test.update_layout(
                margin={'r':0,'t':0,'l':0,'b':0},
                coloraxis_colorbar={
                'title':'<b>Cumulative Cases <br>per 100,000 people</b>',
                'tickvals': values_adj_cc,
                'ticktext': ticks_adj_cc})
            return fig_test


        else:
            fig_test = px.choropleth_mapbox(date_df,
                                      geojson=geo_world_ok,
                                      locations='Country',
                                      color=date_df['count_color_adj_cd'],
                                      color_continuous_scale='ylorrd',
                                      range_color=(0, date_df['count_color_adj_cd'].max()),
                                      hover_name='Country',
                                      hover_data = {'count_color_adj_cd':False,
                                                    'Country':False,
                                                    'Adj. Cumulative Deaths':':,'},
                                      mapbox_style = 'open-street-map',
                                      zoom=1,
                                      center={'lat':19,'lon':11},
                                      opacity=0.6)

            fig_test.update_layout(
                margin={'r':0,'t':0,'l':0,'b':0},
                coloraxis_colorbar={
                'title':'<b>Cumulative Deaths <br>per 100,000 people</b>',
                'tickvals': values_adj_cd,
                'ticktext': ticks_adj_cd})
            return fig_test



#Configure Reactivity for Bar Plots on Tab 3

@app.callback(
    Output('top10cases','figure'),
    Output('top10deaths','figure'),
    Input('slider2','value'),
    Input('radio3','value'))

def update_figure3(date_select_index,radio_select):
    date_select = slider_options.get(date_select_index, "1100-01-01")
    date_df = who_data[(who_data.Date_reported<=date_select)] 
    
    who_data_casemax = date_df.groupby(['Country']).tail(1).sort_values(by=['Cumulative Cases'],ascending=False)[0:11]
    who_data_deadmax = date_df.groupby(['Country']).tail(1).sort_values(by=['Cumulative Deaths'],ascending=False)[0:11]
    
    who_data_casemax_adj = date_df.groupby(['Country']).tail(1).sort_values(by=['Adj. Cumulative Cases'],ascending=False)[0:11]
    who_data_deadmax_adj = date_df.groupby(['Country']).tail(1).sort_values(by=['Adj. Cumulative Deaths'],ascending=False)[0:11]
    
    
    if "No" in radio_select:
        fig = px.bar(who_data_casemax, x='Country', y='Cumulative Cases',
                     title=f'<b>Top 10 Countries by Cumulative Cases on {date_select}</b>',
                     hover_data={'Country':True,'Cumulative Cases':':,'})
        fig2 = px.bar(who_data_deadmax, x='Country', y='Cumulative Deaths',
                      title=f'<b>Top 10 Countries by Cumulative Deaths on {date_select}</b>',
                      hover_data={'Country':True,'Cumulative Deaths':':,'})
    
        fig.update_traces(marker_color='rgb(255,128,0)')
        fig.update_layout(title={'x':0.5,'xanchor': 'center','yanchor': 'top'})


        fig2.update_traces(marker_color='rgb(220,20,60)')
        fig2.update_layout(title={'x':0.5,'xanchor': 'center','yanchor': 'top'})
        
        return (fig, fig2)
        
    
    else:
        fig = px.bar(who_data_casemax_adj, x='Country', y='Adj. Cumulative Cases',
                     hover_data={'Country':True,'Adj. Cumulative Cases':':,'},
                     title=f'<b>Top 10 Countries by Cumulative Cases on {date_select} per 100,000 people</b>')
        fig2 = px.bar(who_data_deadmax_adj, x='Country', y='Adj. Cumulative Deaths',
                      hover_data={'Country':True,'Adj. Cumulative Deaths':':,'},
                      title=f'<b>Top 10 Countries by Cumulative Deaths on {date_select} per 100,000 people</b>')
    
        fig.update_traces(marker_color='rgb(255,128,0)')
        fig.update_layout(title={'x':0.5,'xanchor': 'center','yanchor': 'top'})


        fig2.update_traces(marker_color='rgb(220,20,60)')
        fig2.update_layout(title={'x':0.5,'xanchor': 'center','yanchor': 'top'})        

    
        return (fig, fig2)


#Configure Reactivity for Area Plots on Tab 4

@app.callback(
    Output('figa1','figure'),
    Output('figa2','figure'),
    Input('slider3','value'),
    Input('radio4','value'))

def update_figure4(date_select_index,radio_select):

    #The above needs to happen after the date_select selection
    date_select = slider_options.get(date_select_index, "1100-01-01")
    date_df = who_data[(who_data.Date_reported<=date_select)] 
    
    #Filter data on last 14 days
    end_date = datetime.strptime(date_select, "%Y-%m-%d")
    cut_off = (end_date - pd.offsets.Day(14)).date()
    test = date_df[(date_df['Date_reported']>=str(cut_off))]
    
    if "No" in radio_select:
        #Sort Countries by Sum of New Cases over those 14 days
        test['TotalNewCases14days'] = test.groupby('Country',sort=False)['New Cases'].transform('sum')
        test['TotalNewDeaths14days'] = test.groupby('Country',sort=False)['New Deaths'].transform('sum')

        test_c = test.sort_values(by=['TotalNewCases14days'],ascending=False)
        test_d = test.sort_values(by=['TotalNewDeaths14days'],ascending=False)

        #Only Keep Top 10
        top10_c = test_c['Country'].unique()[0:10]
        top10_d = test_d['Country'].unique()[0:10]

        cleaned_c = test_c[test_c['Country'].isin(top10_c)] 
        cleaned_d = test_d[test_d['Country'].isin(top10_d)] 
    
    
        fig_area = px.area(cleaned_c, x="Date_reported", y="New Cases",labels=dict(Date_reported=""),facet_col="Country",facet_col_wrap=5,title=f'<b>Top 10 Countries by New Cases over Last 14 Days from {date_select}</b>')
        fig_area.for_each_annotation(lambda a: a.update(text=a.text.split("=")[-1]))
        fig_area.update_traces(fillcolor='rgb(255,128,0)', line_color='black',mode="markers+lines")
        fig_area.update_layout(title={'x':0.5,'xanchor': 'center','yanchor': 'top'})



        fig_area2 = px.area(cleaned_d, x="Date_reported", y="New Deaths",labels=dict(Date_reported=""),facet_col="Country",facet_col_wrap=5,title=f'<b>Top 10 Countries by New Deaths over Last 14 Days from {date_select}</b>')
        fig_area2.for_each_annotation(lambda a: a.update(text=a.text.split("=")[-1]))
        fig_area2.update_traces(fillcolor='rgb(220,20,60)', line_color='black',mode="markers+lines")
        fig_area2.update_layout(title={'x':0.5,'xanchor': 'center','yanchor': 'top'})


        return (fig_area, fig_area2)
    else:
        #Sort Countries by Sum of New Cases over those 14 days
        test['TotalNewCases14days'] = test.groupby('Country',sort=False)['Adj. New Cases'].transform('sum')
        test['TotalNewDeaths14days'] = test.groupby('Country',sort=False)['Adj. New Deaths'].transform('sum')

        test_c = test.sort_values(by=['TotalNewCases14days'],ascending=False)
        test_d = test.sort_values(by=['TotalNewDeaths14days'],ascending=False)

        #Only Keep Top 10
        top10_c = test_c['Country'].unique()[0:10]
        top10_d = test_d['Country'].unique()[0:10]

        cleaned_c = test_c[test_c['Country'].isin(top10_c)] 
        cleaned_d = test_d[test_d['Country'].isin(top10_d)] 
    
    
        fig_area = px.area(cleaned_c, x="Date_reported", y="Adj. New Cases",labels=dict(Date_reported=""),facet_col="Country",facet_col_wrap=5,title=f'<b>Top 10 Countries by New Cases over Last 14 Days from {date_select} per 100,000 people</b>')
        fig_area.for_each_annotation(lambda a: a.update(text=a.text.split("=")[-1]))
        fig_area.update_traces(fillcolor='rgb(255,128,0)', line_color='black',mode="markers+lines")
        fig_area.update_layout(title={'x':0.5,'xanchor': 'center','yanchor': 'top'})



        fig_area2 = px.area(cleaned_d, x="Date_reported", y="Adj. New Deaths",labels=dict(Date_reported=""),facet_col="Country",facet_col_wrap=5,title=f'<b>Top 10 Countries by New Deaths over Last 14 Days from {date_select} per 100,000 people</b>')
        fig_area2.for_each_annotation(lambda a: a.update(text=a.text.split("=")[-1]))
        fig_area2.update_traces(fillcolor='rgb(220,20,60)', line_color='black',mode="markers+lines")
        fig_area2.update_layout(title={'x':0.5,'xanchor': 'center','yanchor': 'top'})
        


        return (fig_area, fig_area2)

app.run_server(host='0.0.0.0',port='8055')
# if __name__=='__main__':
# 	app.run_server()
