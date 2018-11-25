import React from 'react';
import map from 'lodash/map';
import Tyre from '../components/Tyre';
import Time from '../components/Time';
import sortBy from 'lodash/sortBy';
import get from 'lodash/get';
import styled from 'styled-components';
import Page from '../Page';

const Table = styled.table`
  width: 100%;
`;

const Row = row => (
  <tr>
    <td>{row.car_position}</td>
    <td>{row.race_number}</td>
    <td>{row.name}</td>
    <td>
      <Time time={row.gap} />
    </td>
    <td>
      <Time time={row.interval} />
    </td>
    <td>
      <Time time={row.last_lap_time} />
    </td>
    <td>
      <Time time={row.sector_one_time} />
    </td>
    <td>
      <Time time={row.sector_two_time} />
    </td>
    <td>
      <Time time={row.sector_three_time} />
    </td>
    <td>
      <Time time={row.best_lap_time} />
    </td>
    <td>
      <Tyre id={row.tyre_compound} />
    </td>
  </tr>
);

const transformTimingInput = unsorted =>
  sortBy(map(unsorted, (p, i) => ({ ...p, index: i })), ({ index }) =>
    get(unsorted, [index, 'car_position']),
  );

const Timing = () => (
  <Page
    name={'timing'}
    transformInput={transformTimingInput}
    render={timing => (
      <Table>
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
          {map(timing, row => (
            <Row key={row.name} {...row} />
          ))}
        </tbody>
      </Table>
    )}
  />
);

export default Timing;
