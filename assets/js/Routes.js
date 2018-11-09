import React from 'react'
import {Route, Switch} from "react-router-dom";
import Session from './pages/Session'
import Timing from './pages/Timing'

const Routes = () => (
    <Switch>
        <Route path={'/'} exact component={Session}/>
        <Route path={'/timing'} component={Timing}/>
    </Switch>
)

export default Routes;