import React, { Component } from 'react';
import { ResponsiveContainer, ComposedChart, Legend, Area, Bar, YAxis, XAxis, Tooltip, CartesianGrid } from 'recharts';
import logo from './svg/logo_black.svg';
import './AllResortsChart.scss';

const HC_VAGRANT_BLUE_LIGHTEST = "#EFF5FF";
const HC_VAGRANT_BLUE_LIGHT = "#66A2FF";
const HC_VAGRANT_BLUE_DARK = "#1563FF";
const HC_VAGRANT_BLUE_DARKEST = "#08368B";

// TODO: pass these in as globals?
const HOST = window.location.hostname;
const PORT = window.location.port;
const CONTAINER_ID_SERVICE_URL = `http://${HOST}:${PORT}/container_id`;
const SNOWFALL_SERVICE_BASE_URL = `http://${HOST}:${PORT}/snowfall`;
const SUPPORTED_RESORTS = ["squaw", "alpine"];

export default class AllResortsChart extends Component {

  static displayName = 'AllResortsChart';

  constructor(props) {
    super(props);
    const initState = {};
    for (var i in SUPPORTED_RESORTS) {
      const resortName = SUPPORTED_RESORTS[i];
      initState[resortName] = []
    }
    this.state = initState;
    this._fetchSnowfallData();
    this._fetchContainerID();
  }

  _fetchContainerID() {
    fetch(CONTAINER_ID_SERVICE_URL)
      .then((response) => {
        return response.json()
      })
      .catch((err) => {
        console.log('Error retrieving container ID.')
      })
      .then((data) => {
        this.setState(data)
      });
  }

  _fetchSnowfallData() {
    for (var i in SUPPORTED_RESORTS) {
      const resortName = SUPPORTED_RESORTS[i];
      const service_url = `${SNOWFALL_SERVICE_BASE_URL}/${resortName}`; 

      fetch(service_url)
        .then((response) => {
          return response.json()
        })
        .catch((err) => {
          console.log(`Error retrieving snowfall data for ${resortName}.`);
        })
        .then((data) => {
          const newState = {}
          newState[resortName] = data;
          this.setState(newState);
        });
    }
  }

  render() {
    // TODO: dynamic keys for charts with headers
    // Colors from Vagrant: https://www.datocms-assets.com/2885/1546893249-hashicorp-brand-guide-jan2019v3.pdf
    return (
      <div className='line-charts'>
        <img src={logo} className="logo" alt="logo" />
        <h1>Winterfall</h1>
        <h5>Served by container ID: {this.state.containerID}</h5>
        <div className='line-chart-wrapper'>
          <h3>Squaw Valley</h3>
          <ResponsiveContainer width="100%" height="100%">
            <ComposedChart
              data={this.state.squaw}
            >
              <defs>
                <linearGradient id="vagrantLighter" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor={HC_VAGRANT_BLUE_LIGHTEST} stopOpacity={0.8} />
                  <stop offset="95%" stopColor={HC_VAGRANT_BLUE_LIGHT} stopOpacity={0} />
                </linearGradient>
                <linearGradient id="vagrantDarker" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor={HC_VAGRANT_BLUE_DARK} stopOpacity={0.8} />
                  <stop offset="95%" stopColor={HC_VAGRANT_BLUE_DARKEST} stopOpacity={0} />
                </linearGradient>
              </defs>

              <XAxis dataKey='date' />
              <YAxis />
              <CartesianGrid stroke='#f5f5f5'/>
              <Tooltip filterNull={false} style={{"background-color": "#0F1013"}}/>
              <Legend />
              <Area key="cumulative_6000" dataKey="cumulative_6000" stroke={HC_VAGRANT_BLUE_DARK} fill="url(#vagrantDarker)" />
              <Bar key="oneday_6000" dataKey="oneday_6000" barSize={20} fill={HC_VAGRANT_BLUE_DARK} opacity="0.5" />
              <Area key="cumulative_8200" dataKey="cumulative_8200" stroke={HC_VAGRANT_BLUE_DARKEST} fill="url(#vagrantLighter)" />
              <Bar key="oneday_8200" dataKey="oneday_8200" barSize={20} fill={HC_VAGRANT_BLUE_DARKEST} opacity="0.5" />
            </ComposedChart>
          </ResponsiveContainer>
        </div>
        <div className='line-chart-wrapper'>
          <h3>Alpine Meadows</h3>
          <ResponsiveContainer width="100%" height="100%">
            <ComposedChart
              data={this.state.alpine}
            >
              <XAxis dataKey='date' />
              <YAxis />
              <CartesianGrid stroke='#f5f5f5'/>
              <Tooltip filterNull={false} />
              <Legend />
              <Area key="cumulative_6000" dataKey="cumulative_6000" stroke={HC_VAGRANT_BLUE_DARK} fill='url(#vagrantDarker)' />
              <Bar key="oneday_6000" dataKey="oneday_6000" barSize={20} fill={HC_VAGRANT_BLUE_DARK} opacity="0.5" />
              <Area key="cumulative_8200" dataKey="cumulative_8200" stroke={HC_VAGRANT_BLUE_DARKEST} fill='url(#vagrantLighter)' />
              <Bar key="oneday_8200" dataKey="oneday_8200" barSize={20} fill={HC_VAGRANT_BLUE_DARKEST} opacity="0.5" />
            </ComposedChart>
          </ResponsiveContainer>
        </div>
      </div>
    );
  }
}