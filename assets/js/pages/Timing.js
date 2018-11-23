import React, {Component} from 'react';
import {Socket} from "phoenix"
import map from 'lodash/map'
import Tyre from "../components/Tyre";
import Time from "../components/Time";
import sortBy from "lodash/sortBy";
import get from "lodash/get";

const Row = (row) => (
    <tr>
        <td>{row.car_position}</td>
        <td>{row.race_number}</td>
        <td>{row.name}</td>
        <td><Time time={row.gap}/></td>
        <td><Time time={row.interval}/></td>
        <td><Time time={row.last_lap_time}/></td>
        <td><Time time={row.sector_one_time}/></td>
        <td><Time time={row.sector_two_time}/></td>
        <td><Time time={row.sector_three_time}/></td>
        <td><Time time={row.best_lap_time}/></td>
        <td><Tyre id={row.tyre_compound}/></td>
    </tr>
);


class Timing extends Component {
    constructor(props) {
        super(props)
        this.state = {}
    }

    updateState = (unsorted) => {
        const timing = sortBy(
            map(unsorted, (p, i) => ({...p, index: i})),
            ({index}) => get(unsorted, [index, 'car_position'])
        );
        this.setState({timing})
    };

    componentDidMount() {
        let socket = new Socket("/socket", {params: {token: window.userToken}})
        socket.connect()

        let channel = socket.channel("telemetry:timing", {})
        channel.on("update", ({timing}) => {
            this.updateState(timing)
        })

        channel.join()
            .receive("ok", resp => {
                console.log("Joined successfully", resp)
            })
            .receive("error", resp => {
                console.log("Unable to join", resp)
            })

        fetch('/api/timing').then(response => {
            response.json().then(({data}) => {
                this.updateState(data)
            })
        })
    }

    render() {
        return (
            <table>
                <thead>
                <tr>
                    <td>POS</td>
                    <td>#</td>
                    <td>NAME</td>
                    <td>GAP</td>
                    <td>INT</td>
                    <td>LAST</td>
                    <td>S1</td>
                    <td>S2</td>
                    <td>S3</td>
                    <td>BEST</td>
                    <td>TYRE</td>
                </tr>
                </thead>
                <tbody>
                {map(this.state.timing, row => <Row key={row.name} {...row} />)}
                </tbody>
            </table>
        );
    }
}

export default Timing;
