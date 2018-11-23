import React from 'react'

const Time = ({time}) => {
    if (time) {
        return `${Math.floor(time / 60)}:${(time % 60).toFixed(3)}`;
    }
    return null;
};

export default Time;