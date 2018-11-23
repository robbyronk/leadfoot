const Tyre = ({ id }) => {
  switch (id) {
    case 0:
      return 'HS';
    case 1:
      return 'US';
    case 2:
      return 'SS';
    case 3:
      return 'S';
    case 4:
      return 'M';
    case 5:
      return 'H';
    case 6:
      return 'SH';
    case 7:
      return 'I';
    case 8:
      return 'W';
  }
  return 'Unknown';
};

export default Tyre;
