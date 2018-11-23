import React from 'react';
import { Route, Switch } from 'react-router-dom';
import Session from './pages/Session';
import Timing from './pages/Timing';
import map from 'lodash/map';
import { Redirect } from 'react-router';

export const routesList = [
  {
    label: 'Session',
    route: {
      path: '/',
      exact: true,
      component: Session,
    },
  },
  {
    label: 'Timing',
    route: {
      path: '/timing',
      component: Timing,
    },
  },
];

const Routes = () => (
  <Switch>
    {map(routesList, ({ route }) => (
      <Route key={route.path} {...route} />
    ))}
    <Redirect to={'/'} />
  </Switch>
);

export default Routes;
