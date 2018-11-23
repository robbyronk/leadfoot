const SessionType = ({ id }) => {
  switch (id) {
    case 1:
      return 'P1';
    case 2:
      return 'P2';
    case 3:
      return 'P3';
    case 4:
      return 'Short P';
    case 5:
      return 'Q1';
    case 6:
      return 'Q2';
    case 7:
      return 'Q3';
    case 8:
      return 'Short Q';
    case 9:
      return 'One Shot Q';
    case 10:
      return 'Race';
    case 11:
      return 'Race2';
    case 12:
      return 'Time Trial';
  }
  return 'Unknown';
};

export default SessionType;
