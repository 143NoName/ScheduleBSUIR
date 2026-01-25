//
//  ScheduleBSUIRTests.swift
//  ScheduleBSUIRTests
//
//  Created by andrew on 25.01.26.
//

import XCTest
import Testing
@testable import ScheduleBSUIR
//@testable import ScheduleBSUIRWidgetExtension

// тесты для виджета
//final class ScheduleBSUIRWidgetTests: XCTestCase {
//    
//    func testFilterInWidget() {
//        // данные для функции
//        let lessons: [Lesson] = [
//            Lesson(auditories: [], endLessonTime: "", lessonTypeAbbrev: "", note: nil, numSubgroup: 0, startLessonTime: "", studentGroups: [], subject: "", subjectFullName: "", weekNumber: [1, 2, 3], employees: nil, dateLesson: nil, startLessonDate: nil, endLessonDate: nil, announcement: false, split: false)
//        ]
//        let weekNumber = 4
//        let subGroup: SubGroupInPicker = .all
//        
//        let filterInWidget = FilterInWidget()
//        
//        // сама функция
//        let filterByWeekAndSubGroup = filterInWidget.filterLessons(lessons: lessons)
//
//        // ожидание
//        
//        XCTAssertEqual(filterByWeekAndSubGroup, [])
//    }
//}

final class ScheduleBSUIRTests: XCTestCase {
    
    func testExample() {
        let lesson: Lesson = Lesson(auditories: [], endLessonTime: "18:50", lessonTypeAbbrev: "", note: nil, numSubgroup: 1, startLessonTime: "12:10", studentGroups: [], subject: "", subjectFullName: "", weekNumber: [1, 2, 3, 4], employees: nil, dateLesson: nil, startLessonDate: nil, endLessonDate: nil, announcement: false, split: false)
        let moreFunctions = MoreFunctions()
        
        let result = moreFunctions.comparisonLessonOverTime(lesson: lesson)
        
        XCTAssertEqual(result, false)
    }
}

final class MoreFunctionsTests {
    let moreFuncs = MoreFunctions()
    
    @Test func testComparisonDay() {
        let result = moreFuncs.comparisonDay(.sunday, lessonDay: "Воскреенье")
        
        #expect(result == false)
    }
}


