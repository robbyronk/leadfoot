import React, {Component} from 'react';
import {Socket} from "phoenix"
import map from 'lodash/map'
import faker from 'faker'

const fake = () => ({
    name: faker.name.findName(),
    number: faker.random.number(),
})

const Row = (row) => (
    <tr>
        <td>{row.position}</td>
        <td>{row.number}</td>
        <td>{row.name}</td>
        <td>{row.gap}</td>
        <td>{row.interval}</td>
        <td>{row.lastLap}</td>
        <td>{row.sector1}</td>
        <td>{row.sector2}</td>
        <td>{row.sector3}</td>
        <td>{row.best}</td>
        <td>{row.tyre}</td>
    </tr>
);


class Timing extends Component {
    constructor(props) {
        super(props)
        this.state = {
            timing: [
                fake(),
                fake(),
                fake(),
                fake(),
                fake(),
            ]
        }
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
