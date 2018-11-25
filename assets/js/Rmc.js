import React, { Component } from 'react';
import { Panel, PanelBody, PanelHeader } from './components';
import Routes from './Routes';
import Nav from './components/Nav';

class Rmc extends Component {
  render() {
    return (
      <Panel>
        <PanelHeader>{'|>RACE CONTROL'}</PanelHeader>
        <Nav />
        <PanelBody>
          <Routes />
        </PanelBody>
      </Panel>
    );
  }
}

export default Rmc;
