import React, {Component} from 'react';
import {ThemeProvider} from 'styled-components'
import Participants from './Participants'
import {Panel, PanelBody, PanelHeader, Tab, Tabs} from "./components";
import theme from "./theme";

class Rmc extends Component {
    render() {
        return (
            <ThemeProvider theme={theme}>
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
                        <Participants/>
                    </PanelBody>
                </Panel>
            </ThemeProvider>
        );
    }
}

export default Rmc;
