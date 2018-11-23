import React from 'react';
import PropTypes from 'prop-types';
import { withRouter } from 'react-router';
import { Tab, Tabs } from './index';
import map from 'lodash/map';
import { routesList } from '../Routes';

const makeTab = (pathname, history) =>
  function NavTab({ label, route }) {
    return (
      <Tab
        key={route.path}
        active={pathname === route.path}
        onClick={() => history.push(route.path)}
      >
        {label}
      </Tab>
    );
  };

const Nav = ({ location, history }) => {
  const { pathname } = location;
  return <Tabs>{map(routesList, makeTab(pathname, history))}</Tabs>;
};

Nav.propTypes = {
  location: PropTypes.shape({
    pathname: PropTypes.string,
  }),
  history: PropTypes.shape({
    push: PropTypes.func,
  }),
};

export default withRouter(Nav);
