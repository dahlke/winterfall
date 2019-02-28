import React, { Component } from 'react';

import AllResortsChart from './chart/AllResortsChart';
import './App.scss';

class App extends Component {
  render() {
    return (
      <div className="App">
        <AllResortsChart />
      </div>
    );
  }
}

export default App;