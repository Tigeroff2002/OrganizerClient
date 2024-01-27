import 'package:todo_calendar_client/models/enums/DecisionType.dart';
import 'package:todo_calendar_client/models/enums/EventType.dart';
import 'package:todo_calendar_client/models/enums/EventStatus.dart';
import 'package:todo_calendar_client/models/enums/GroupType.dart';
import 'package:todo_calendar_client/models/enums/ReportType.dart';
import 'package:todo_calendar_client/models/enums/TaskCurrentStatus.dart';
import 'package:todo_calendar_client/models/enums/TaskType.dart';

final class EnumAliaser{
  String GetAlias(Object enumValue){
    if (enumValue is DecisionType){
      if (enumValue == DecisionType.None){
        return 'Без статуса';
      }
      else if (enumValue == DecisionType.Default){
        return 'По умолчанию';
      }
      else if (enumValue == DecisionType.Apply){
        return 'Собирается посетить';
      }
      else if (enumValue == DecisionType.Default){
        return 'Не будет присутствовать';
      }
    }
    else if (enumValue is EventStatus){
      if (enumValue == EventStatus.None){
        return 'Без статуса';
      }
      else if (enumValue == EventStatus.Cancelled){
        return 'Отменено';
      }
      else if (enumValue == EventStatus.NotStarted){
        return 'Не начато';
      }
      else if (enumValue == EventStatus.WithinReminderOffset){
        return 'Скоро начнется';
      }
      else if (enumValue == EventStatus.Live){
        return 'Идет сейчас';
      }
      else if (enumValue == EventStatus.Finished){
        return 'Завершено';
      }
    }
    else if (enumValue is EventType){
      if (enumValue == EventType.None){
        return 'Без статуса';
      }
      else if (enumValue == EventType.Personal){
        return 'Личное';
      }
      else if (enumValue == EventType.OneToOne){
        return 'Парное';
      }
      else if (enumValue == EventType.StandUp){
        return 'Стэндап команды';
      }
      else if (enumValue == EventType.Meeting){
        return 'Общее собрание';
      }
    }
    else if (enumValue is GroupType){
      if (enumValue == GroupType.None){
        return 'Без статуса';
      }
      else if (enumValue == GroupType.Educational){
        return 'Учебная';
      }
      else if (enumValue == GroupType.Job){
        return 'Рабочая';
      }
    }
    else if (enumValue is SnapshotType){
      if (enumValue == SnapshotType.None){
        return 'Без статуса';
      }
      else if (enumValue == SnapshotType.TasksSnapshot){
        return 'По задачам пользователя';
      }
      else if (enumValue == SnapshotType.EventsSnapshot){
        return 'По мероприятиям пользователя';
      }
      else if (enumValue == SnapshotType.ReportsSnapshot){
        return 'По отчетам пользователя';
      }
      else if (enumValue == SnapshotType.IssuesSnapshot){
        return 'По вопросам пользователя';
      }
    }
    else if (enumValue is TaskCurrentStatus){
      if (enumValue == TaskCurrentStatus.None){
        return 'Без статуса';
      }
      else if (enumValue == TaskCurrentStatus.ToDo){
        return 'Ожидает выполнения';
      }
      else if (enumValue == TaskCurrentStatus.InProgress){
        return 'В процессе';
      }
      else if (enumValue == TaskCurrentStatus.Review){
        return 'На стадии оценки';
      }
      else if (enumValue == TaskCurrentStatus.Done){
        return 'Выполнена';
      }
    }
    else if (enumValue is TaskType){
      if (enumValue == TaskType.None){
        return 'Без статуса';
      }
      else if (enumValue == TaskType.AbstractGoal){
        return 'Абстрактная цель';
      }
      else if (enumValue == TaskType.MeetingPresense){
        return 'Цель посещения мероприятий';
      }
      else if (enumValue == TaskType.JobComplete){
        return 'Цель в выполнении работы';
      }
    }

    return 'Без статуса';
  }

  GroupType getGroupEnumValue(String naming){
    if (naming == 'Educational'){
      return GroupType.Educational;
    }
    else if (naming == 'Job'){
      return GroupType.Job;
    }
    else return GroupType.None;
  }

  EventType getEventTypeEnumValue(String naming){
    if (naming == 'Personal'){
      return EventType.Personal;
    }
    else if (naming == 'OneToOne'){
      return EventType.OneToOne;
    }
    else if (naming == 'StandUp'){
      return EventType.StandUp;
    }
    else if (naming == 'Meeting'){
      return EventType.Meeting;
    }
    else return EventType.None;
  }

  EventStatus getEventStatusEnumValue(String naming){
    if (naming == 'NotStarted'){
      return EventStatus.NotStarted;
    }
    else if (naming == 'WithinReminderOffset'){
      return EventStatus.WithinReminderOffset;
    }
    else if (naming == 'Live'){
      return EventStatus.Live;
    }
    else if (naming == 'Finished'){
      return EventStatus.Finished;
    }
    else if (naming == 'Cancelled'){
      return EventStatus.Cancelled;
    }
    else return EventStatus.None;
  }

  TaskType getTaskTypeEnumValue(String naming){
    if (naming == 'AbstractGoal'){
      return TaskType.AbstractGoal;
    }
    else if (naming == 'MeetingPresense'){
      return TaskType.MeetingPresense;
    }
    else if (naming == 'JobComplete'){
      return TaskType.JobComplete;
    }
    else return TaskType.None;
  }

  TaskCurrentStatus getTaskStatusEnumValue(String naming){
    if (naming == 'ToDo'){
      return TaskCurrentStatus.ToDo;
    }
    else if (naming == 'InProgress'){
      return TaskCurrentStatus.InProgress;
    }
    else if (naming == 'Review'){
      return TaskCurrentStatus.Review;
    }
    else if (naming == 'Done'){
      return TaskCurrentStatus.Done;
    }
    else return TaskCurrentStatus.None;
  }

  SnapshotType getSnapshotTypeEnumValue(String naming){
    if (naming == 'EventsSnapshot'){
      return SnapshotType.EventsSnapshot;
    }
    else if (naming == 'TasksSnapshot'){
      return SnapshotType.TasksSnapshot;
    }
    else if (naming == 'ReportsSnapshot'){
      return SnapshotType.ReportsSnapshot;
    }
    else if (naming == 'IssuesSnapshot'){
      return SnapshotType.IssuesSnapshot;
    }
    else return SnapshotType.None;
  }

  DecisionType getDecisionTypeEnumValue(String naming){
    if (naming == 'Default'){
      return DecisionType.Default;
    }
    else if (naming == 'Apply'){
      return DecisionType.Apply;
    }
    else if (naming == 'Deny'){
      return DecisionType.Deny;
    }
    else return DecisionType.None;
  }
}