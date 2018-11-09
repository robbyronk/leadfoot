import React, {Component} from 'react';
import {Panel, PanelBody, PanelHeader, Tab, Tabs} from "./components";
import Routes from "./Routes";

class Rmc extends Component {
    render() {
        return (
            <Panel>
                <PanelHeader>
                    <h2>
                        |>RACE CONTROL
                    </h2>
                </PanelHeader>
                <Tabs>
                    <Tab active>
                        Session
                    </Tab>
                    <Tab>
                        Timing
                    </Tab>
                    <Tab>
                        Map
                    </Tab>
                    <Tab>
                        Vehicle
                    </Tab>
                    <Tab>
                        Laps
                    </Tab>
                </Tabs>
                <PanelBody>
                    <Routes/>
                </PanelBody>
            </Panel>
        );
    }
}

export default Rmc;
