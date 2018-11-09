import React, {Component} from 'react';
import {Panel, PanelBody, PanelHeader, Tab, Tabs} from "./components";
import Routes from "./Routes";
import Nav from "./components/Nav";

class Rmc extends Component {
    render() {
        return (
            <Panel>
                <PanelHeader>
                    <h2>
                        |>RACE CONTROL
                    </h2>
                </PanelHeader>
                <Nav/>
                <PanelBody>
                    <Routes/>
                </PanelBody>
            </Panel>
        );
    }
}

export default Rmc;
