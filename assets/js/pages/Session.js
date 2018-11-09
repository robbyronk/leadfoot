import React, {Component} from 'react';
import {Socket} from "phoenix"
import map from 'lodash/map'
import get from 'lodash/get'
import sortBy from 'lodash/sortBy'



class Session extends Component {
    constructor(props) {
        super(props)
        this.state = {}
    }

    componentDidMount() {
        let socket = new Socket("/socket", {params: {token: window.userToken}})
        socket.connect()

        let channel = socket.channel("telemetry:session", {})
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
            <div>

            </div>
        );
    }
}

export default Session;
