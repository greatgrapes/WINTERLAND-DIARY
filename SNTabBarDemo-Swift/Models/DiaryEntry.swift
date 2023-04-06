//
//  DiaryEntry.swift
//  winterland
//
//  Created by 박진성 on 2023/02/20.
//

import Foundation
import UIKit

struct DiaryEntry {
    var title: String
    var date: Date
    }


class DiaryEntryModel {
    static var diaryEntries = [DiaryEntry]()
}
