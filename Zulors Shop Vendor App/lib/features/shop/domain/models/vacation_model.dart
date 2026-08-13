class VacationModel {
  bool? vacationStatus;
  String? vacationDurationType;
  String? vacationStartDate;
  String? vacationEndDate;
  String? vacationNote;
  String? method;

  VacationModel(
      {this.vacationStatus,
        this.vacationDurationType,
        this.vacationStartDate,
        this.vacationEndDate,
        this.vacationNote,
        this.method = 'put',
      });

  VacationModel.fromJson(Map<String, dynamic> json) {
    vacationStatus = json['vacation_status'];
    vacationDurationType = json['vacation_duration_type'];
    vacationStartDate = json['vacation_start_date'];
    vacationEndDate = json['vacation_end_date'];
    vacationNote = json['vacation_note'];
    method = 'put';
  }

  Map<String, dynamic> toJson() {
    return {
      'vacation_status': vacationStatus,
      'vacation_duration_type': vacationDurationType,
      'vacation_start_date': vacationStartDate,
      'vacation_end_date': vacationEndDate,
      'vacation_note': vacationNote,
      '_method': method,
    };
  }

}
