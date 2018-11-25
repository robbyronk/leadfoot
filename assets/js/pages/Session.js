import React from 'react';
import Weather from '../components/Weather';
import SessionType from '../components/SessionType';
import TrackName from '../components/TrackName';
import Page from '../Page';

const Session = () => (
  <Page
    name={'session'}
    render={({
      total_laps,
      track_temperature,
      air_temperature,
      weather,
      session_type,
      track_id,
    }) => (
      <div>
        <TrackName id={track_id} />
        <ul>
          <li>
            Session Type: <SessionType id={session_type} />
          </li>
          <li>Laps: {total_laps}</li>
          <li>
            Weather: <Weather id={weather} />
          </li>
          <li>Track Temperature: {track_temperature}°</li>
          <li>Air Temperature: {air_temperature}°</li>
        </ul>
      </div>
    )}
  />
);

export default Session;
