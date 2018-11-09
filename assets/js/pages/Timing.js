import React, {Component} from 'react';
import {Socket} from "phoenix"
import map from 'lodash/map'
import get from 'lodash/get'
import sortBy from 'lodash/sortBy'



class Timing extends Component {
    constructor(props) {
        super(props)
        this.state = {}
    }

    componentDidMount() {
        let socket = new Socket("/socket", {params: {token: window.userToken}})
        socket.connect()

        let channel = socket.channel("telemetry:timing", {})
        channel.on("data_point", payload => {
            console.log(payload)
            this.setState({data: payload})
        })

        channel.join()
            .receive("ok", resp => {
                console.log("Joined successfully", resp)
            })
            .receive("error", resp => {
                console.log("Unable to join", resp)
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
            </table>
        );
    }
}

export default Timing;
