//
//  BugFixes.swift
//  BRBONTests
//
//  Created by Marinus van der Lugt on 03/11/2019.
//

import XCTest
import BRBON


fileprivate let COMMENT_SEQUENCE_NUMBER_NF = NameField("sn")!
fileprivate let COMMENT_SEQUENCE_NUMBER_CS = ColumnSpecification(type: .uint16, nameField: COMMENT_SEQUENCE_NUMBER_NF, byteCount: 2)
fileprivate let COMMENT_SEQUENCE_NUMBER_CI = 0

fileprivate let COMMENT_URL_NF = NameField("cu")!
fileprivate let COMMENT_URL_CS = ColumnSpecification(type: .string, nameField: COMMENT_URL_NF, byteCount: 128)
fileprivate let COMMENT_URL_CI = 1

fileprivate var COMMENT_URL_TABLE_SPECIFICATION = [COMMENT_SEQUENCE_NUMBER_CS, COMMENT_URL_CS]

fileprivate let URL_TABLE_NF = NameField("ctb")!
fileprivate let NOF_COMMENTS_NF = NameField("nofc")!


class BugFixes: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDictTable() {
        // Found in v1.0.1
        // Expansion of a table in a dictionary overwrites the items after the table
        
        let im = ItemManager.createDictionaryManager()
        let tm = ItemManager.createTableManager(columns: &COMMENT_URL_TABLE_SPECIFICATION)
        im.root.updateItem(tm, withNameField: URL_TABLE_NF)
        im.root.updateItem(UInt16(0), withNameField: NOF_COMMENTS_NF)

        guard let table = im.root[URL_TABLE_NF].portal else {
            XCTFail()
            return
        }

        table.addRows(1) { (portal) in
            switch portal.column {
            case COMMENT_URL_CI: portal.string = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            case COMMENT_SEQUENCE_NUMBER_CI: portal.uint16 = 0x7777
            default:
                XCTFail()
            }
        }

        guard let oldCount = im.root[NOF_COMMENTS_NF].uint16 else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(oldCount, 0)
                
        im.root[NOF_COMMENTS_NF] = UInt16(0x5555)

        table.addRows(1) { (portal) in
            switch portal.column {
            case COMMENT_URL_CI: portal.string = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            case COMMENT_SEQUENCE_NUMBER_CI: portal.uint16 = 0x6666
            default:
                XCTFail()
            }
        }

        guard let aCount = im.root[NOF_COMMENTS_NF].uint16 else {
            XCTFail()
            return
        }

        XCTAssertEqual(aCount, 0x5555)
    }
}
