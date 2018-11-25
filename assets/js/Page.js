import { Component } from 'react';
import { Socket } from 'phoenix';
import PropTypes from 'prop-types';

class Page extends Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  componentDidMount() {
    const { name, transformInput } = this.props;
    const socket = new Socket('/socket', {
      params: { token: window.userToken },
    });
    socket.connect();

    const channel = socket.channel(`telemetry:${name}`, {});
    channel.on('update', payload => {
      this.setState({ data: transformInput(payload) });
    });

    channel
      .join()
      .receive('ok', resp => {
        console.log('Joined successfully', resp);
      })
      .receive('error', resp => {
        console.log('Unable to join', resp);
      });

    fetch(`/api/${name}`).then(response => {
      response.json().then(({ data }) => {
        this.setState({ data: transformInput(data) });
      });
    });
  }

  render() {
    if (!this.state.data) {
      return null;
    }
    return this.props.render(this.state.data);
  }
}

Page.propTypes = {
  name: PropTypes.string.isRequired,
  render: PropTypes.func.isRequired,
  transformInput: PropTypes.func,
};

Page.defaultProps = {
  transformInput: x => x,
};

export default Page;
