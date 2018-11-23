import React from 'react';
import ReactDOM from 'react-dom';
import Rmc from './Rmc';
import { BrowserRouter as Router } from 'react-router-dom';
import { ThemeProvider } from 'styled-components';
import 'phoenix_html';

// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import '../css/app.css';
import 'sanitize.css';

import theme from './theme';

const App = () => (
  <Router>
    <ThemeProvider theme={theme}>
      <Rmc />
    </ThemeProvider>
  </Router>
);

ReactDOM.render(<App />, document.getElementById('main'));
