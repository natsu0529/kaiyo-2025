enum Department {
  ENG,
  LOG,
  CAP,
}

extension DepartmentName on Department {
  String get code {
    switch (this) {
      case Department.ENG:
        return 'ENG';
      case Department.LOG:
        return 'LOG';
      case Department.CAP:
        return 'CAP';
    }
  }
}

extension DepartmentLabel on Department {
  String get label {
    switch (this) {
      case Department.CAP:
        return 'デッキ';
      case Department.ENG:
        return 'エンジン';
      case Department.LOG:
        return '流通';
    }
  }
}
