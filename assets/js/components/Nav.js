import React from 'react'
import {withRouter} from 'react-router'
import {Tab, Tabs} from "./index";
import map from 'lodash/map'
import {routesList} from '../Routes'

const makeTab = (pathname, history) => ({label, route}) =>
    (
        <Tab
            key={route.path}
            active={pathname === route.path}
            onClick={() => history.push(route.path)}
        >
            {label}
        </Tab>
    )

const Nav = ({match, location, history}) => {
    const {pathname} = location;
    return (
        <Tabs>
            {map(routesList, makeTab(pathname, history))}
        </Tabs>
    );
}

export default withRouter(Nav)