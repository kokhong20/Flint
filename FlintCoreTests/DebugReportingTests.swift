//
//  DebugReportingTests.swift
//  FlintCore
//
//  Created by Marc Palmer on 16/03/2018.
//  Copyright © 2018 Montana Floss Co. Ltd. All rights reserved.
//

import XCTest
@testable import FlintCore

class DebugReportingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        Flint.resetForTesting()
    }
    
    func testGatheringEmptyZipReport() {
        let zipUrl = DebugReporting.gatherReportZip(options: [.machineReadableFormat])
        XCTAssert(FileManager.default.fileExists(atPath: zipUrl.path))
    }

    func testGatheringZipReport() {
        Flint.quickSetup(DummyFeatures.self, domains: [], initialDebugLogLevel: .none, initialProductionLogLevel: .none)
        DummyFeature.action1.perform()
        let zipUrl = DebugReporting.gatherReportZip(options: [.machineReadableFormat])
        XCTAssert(FileManager.default.fileExists(atPath: zipUrl.path))
    }
}

