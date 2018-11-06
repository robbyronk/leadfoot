import React, {Component} from 'react';
import styled, {ThemeProvider} from 'styled-components'
import path from 'lodash/fp/path';
import Participants from './Participants'

const theme = {
    // can also look at colours with max brightness and saturation
    // some colours inspired from rgbi palette
    red: '#FF5555',
    purple: '#c800ff',
    green: '#55FF55',
    blue: '#51cdef',
    darkBlue: '#2b566c',
    yellow: '#FFFF55',
    orange: '#ffc03a',
    grey: [
        '#010101',
        '#282828',
        '#444',
        '#666',
        '#888',
        '#bbb',
        '#ddd',
        '#fefefe',
    ],
    fontFamily: 'Fira Code, Sans-Serif;'
}

const Button = styled.button`
  background: ${path('theme.blue')};
  border-radius: 3px;
  border: 2px solid ${path('theme.blue')};
  color: ${path('theme.grey[0]')};
  margin: 0 1em;
  padding: 0.25em 1em;
`

const PurpleButton = styled(Button)`
  background: ${path('theme.purple')};
  border: 2px solid ${path('theme.purple')};
  color: ${path('theme.grey[0]')};
`

const YellowButton = styled(Button)`
  background: ${path('theme.yellow')};
  border: 2px solid ${path('theme.yellow')};
  color: ${path('theme.grey[0]')};
`

const Panel = styled.div`
  min-height: 100vh;
  background-color: ${path('theme.grey[0]')};
  display: grid;
  border: 5px solid ${path('theme.blue')};
  grid-template-rows: 5em auto;
  font-family: ${path('theme.fontFamily')};
`

const PanelHeader = styled.div`
  background-color: ${path('theme.darkBlue')};
  color: ${path('theme.grey[7]')};
  padding: 0.5em 1em;
  border-bottom: 5px solid ${path('theme.blue')};
`

const PanelBody = styled.div`
  color: ${path('theme.grey[7]')};
`

const ParticipantsGrid = styled.div`
  padding: 1em;
  display: grid;
  grid-template-columns: 3em repeat(auto-fit, minmax(100px, 1fr));
`

const YellowText = styled.div`
  color: ${path('theme.yellow')};
`


class Rmc extends Component {
    render() {
        return (
            <ThemeProvider theme={theme}>
                <Panel>
                    <PanelHeader>
                        <h2>
                            |>RACE CONTROL
                        </h2>
                    </PanelHeader>
                    <PanelBody>
                        <Participants/>
                    </PanelBody>
                </Panel>
            </ThemeProvider>
        );
    }
}

export default Rmc;
