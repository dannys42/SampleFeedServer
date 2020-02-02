//
//  ConfigParameters.swift
//  
//
//  Created by Danny Sung on 01/30/2020.
//

import Vapor

public class ConfigParameters {
    enum Failures: Error, CustomStringConvertible {
        case missingEnvVar(String)
        
        public var description: String {
            switch self {
                case let .missingEnvVar(variable): return "Missing enviroment variable '\(variable)'"
            }
        }
    }

    public static var dbfile: String = "DBFILE"
    public var dbfile: String
    
    public required init() throws {
        guard let dbfile: String = Environment.get(ConfigParameters.dbfile) else {
            throw Failures.missingEnvVar(ConfigParameters.dbfile)
        }
        self.dbfile = dbfile
    }
}
