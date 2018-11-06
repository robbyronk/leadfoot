import React, {Component} from 'react';
import styled from 'styled-components'
import {Socket} from "phoenix"
import map from 'lodash/map'
import get from 'lodash/get'
import sortBy from 'lodash/sortBy'
import Time from './Time'

const ParticipantsGrid = styled.div`
  padding: 1em;
`

const Grid = styled.div`
  display: grid;
  grid-template-columns: 3em repeat(auto-fit, minmax(100px, 1fr));
`


const Row = ({
                 position,
                 name,
                 gainedPlaces,
                 lastLap,
                 bestLap,
                 pitStatus,
                 timePenalty,
                 currentLapNum,
                 trackLength,
                 lapDistance,
                 safteyCarDelta,
             }) =>
    (
        <Grid>
            <div>{position}</div>
            <div>{name}</div>
            <div><Time secs={lastLap}/></div>
            <div><Time secs={bestLap}/></div>
            <div>{timePenalty > 0 ? timePenalty : null}</div>
            <div>{safteyCarDelta}</div>
            <div>{currentLapNum}</div>
            <div>{lapDistance > 0 ? (100 * (trackLength - lapDistance) / trackLength).toFixed(2) : null}</div>
        </Grid>
    );

class Participants extends Component {
    constructor(props) {
        super(props)
        this.state = {}
    }

    componentDidMount() {
        let socket = new Socket("/socket", {params: {token: window.userToken}})
        socket.connect()

        let channel = socket.channel("telemetry:f1", {})
        channel.on("data_point", payload => {
            this.handleDataPoint(payload)
        })

        channel.join()
            .receive("ok", resp => {
                console.log("Joined successfully", resp)
            })
            .receive("error", resp => {
                console.log("Unable to join", resp)
            })
    }

    handleDataPoint(data) {
        const {packet_header, participants, laps, track_length} = data;
        if (!this.state.playerCarIndex) {
            this.setState({playerCarIndex: packet_header.player_car_index});
        }
        if (!this.state.trackLength && track_length) {
            this.setState({trackLength: track_length})
        }
        if (participants) {
            this.setState({participants});
        }
        if (laps) {
            this.setState({laps})
        }
    }


    render() {
        const {participants, laps, trackLength} = this.state;
        return (
            <ParticipantsGrid>
                {}
                {map(
                    sortBy(
                        map(participants, (p, i) => ({...p, index: i})),
                        ({index}) => get(laps, [index, 'car_position'])
                    ),
                    p =>
                        <Row
                            key={p.index}
                            name={p.name}
                            bestLap={get(laps, [p.index, 'best_lap_time'])}
                            lastLap={get(laps, [p.index, 'last_lap_time'])}
                            timePenalty={get(laps, [p.index, 'penalties'])}
                            position={get(laps, [p.index, 'car_position'])}
                            currentLapNum={get(laps, [p.index, 'current_lap_num'])}
                            safteyCarDelta={get(laps, [p.index, 'safety_car_delta'])}
                            lapDistance={get(laps, [p.index, 'lap_distance'])}
                            trackLength={trackLength}
                        />
                )}
            </ParticipantsGrid>
        );
    }
}

export default Participants;
