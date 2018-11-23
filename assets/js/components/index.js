import styled from 'styled-components';
import path from 'lodash/fp/path';

export const Button = styled.button`
  background: ${path('theme.blue')};
  border-radius: 3px;
  border: 2px solid ${path('theme.blue')};
  color: ${path('theme.grey[0]')};
  margin: 0 1em;
  padding: 0.25em 1em;
`;

export const PurpleButton = styled(Button)`
  background: ${path('theme.purple')};
  border: 2px solid ${path('theme.purple')};
  color: ${path('theme.grey[0]')};
`;

export const YellowButton = styled(Button)`
  background: ${path('theme.yellow')};
  border: 2px solid ${path('theme.yellow')};
  color: ${path('theme.grey[0]')};
`;

export const Panel = styled.div`
  min-height: 100vh;
  background-color: ${path('theme.grey[0]')};
  display: grid;
  border: 5px solid ${path('theme.blue')};
  grid-template-rows: 5em 5em auto;
  font-family: ${path('theme.fontFamily')};
`;

export const PanelHeader = styled.div`
  background-color: ${path('theme.darkBlue')};
  color: ${path('theme.grey[7]')};
  padding: 0.5em 1em;
  border-bottom: 5px solid ${path('theme.blue')};
`;

export const PanelBody = styled.div`
  color: ${path('theme.grey[7]')};
`;

export const ParticipantsGrid = styled.div`
  padding: 1em;
  display: grid;
  grid-template-columns: 3em repeat(auto-fit, minmax(100px, 1fr));
`;

export const YellowText = styled.div`
  color: ${path('theme.yellow')};
`;

export const Tabs = styled.div`
  padding: 0;
  margin: 0;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
  border-bottom: 5px solid ${path('theme.blue')};
`;

export const Tab = styled.div`
  background-color: ${props =>
    props.active ? props.theme.darkBlue : 'transparent'};
  color: ${path('theme.white')};
  padding: 1em;
  &:not(:last-child) {
    border-right: 5px solid ${path('theme.blue')};
  }
  text-align: center;
`;
