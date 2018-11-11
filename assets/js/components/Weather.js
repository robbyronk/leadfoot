import React from 'react'

const Weather = ({id}) => {
    switch (id) {
        case 0:
            return 'Clean';
        case 1:
            return 'Light Clouds';
        case 2:
            return 'Overcast';
        case 3:
            return 'Light Rain';
        case 4:
            return 'Heavy Rain';
        case 5:
            return 'Storm';
    }
    return 'Unknown';
}

export default Weather;