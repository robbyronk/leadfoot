import React, {Component} from 'react';

class Time extends Component {
  render() {
    const {secs} = this.props;
    var minutes = Math.floor(secs / 60);
    var seconds = secs - minutes * 60;
    return `${minutes}:${seconds.toFixed(3)}`;
  }
}

export default Time;
