import React, {Component} from 'react';
import {ThemeProvider} from 'styled-components'
import Participants from './Participants'
import {Panel, PanelBody, PanelHeader, Tab, Tabs} from "./components";

const theme = {
    // can also look at colours with max brightness and saturation
    // some colours inspired from rgbi palette
    red: '#FF5555',
    purple: '#c800ff',
    green: '#55FF55',
    blue: '#51cdef',
    darkBlue: '#2b566c',
    yellow: '#FFFF55',
    orange: '#ffc03a',
    grey: [
        '#010101',
        '#282828',
        '#444',
        '#666',
        '#888',
        '#bbb',
        '#ddd',
        '#fefefe',
    ],
    white: '#fefefe',
    fontFamily: 'Fira Code, Sans-Serif;'
}

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
