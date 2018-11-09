import React, {Component} from 'react';
import {Socket} from "phoenix"

class Session extends Component {
    constructor(props) {
        super(props)
        this.state = {}
    }

    componentDidMount() {
        let socket = new Socket("/socket", {params: {token: window.userToken}})
        socket.connect()

        let channel = socket.channel("telemetry:session", {})
        channel.on("update", payload => {
            this.setState({data: payload})
        })

        channel.join()
            .receive("ok", resp => {
                console.log("Joined successfully", resp)
            })
            .receive("error", resp => {
                console.log("Unable to join", resp)
            })

        fetch('/api/session').then(response => {
            response.json().then(({session}) => {
                this.setState({data: session})
            })
        })
    }


    render() {
        if (!this.state.data) {
            return null;
        }
        const {total_laps, track_temperature, air_temperature} = this.state.data;
        return (
            <div>
                Australia
                <ul>
                    <li>Session Type: Race</li>
                    <li>Laps: {total_laps}</li>
                    <li>Weather: Clear</li>
                    <li>Track Temperature: {track_temperature}°</li>
                    <li>Air Temperature: {air_temperature}°</li>
                </ul>
            </div>
        );
    }
}

export default Session;
