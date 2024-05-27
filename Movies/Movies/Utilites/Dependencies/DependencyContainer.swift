//
//  DependencyContainer.swift
//  Movies
//
//  Created by Michelle on 25/05/2024.
//

import Foundation

@propertyWrapper
struct Dependency<T> {
    
    var dependency: T

    init() {
        guard let resolved = DependencyContainer.resolve(T.self) else {
            fatalError("No Dependency Resolved for \(T.self)")
        }
        dependency = resolved
    }
    
    var wrappedValue: T {
        get { dependency }
        set { dependency = newValue }
    }
}

class DependencyContainer {
    
    private static var factories: [String: () -> Any] = [:]
    
    private static func register<T>(_ dependency: T.Type, _ factory: @autoclosure @escaping () -> T) {
        factories[String(describing: T.self)] = factory
    }
    
    static func resolve<T>(_ dependency: T.Type) -> T? {
        factories[String(describing: dependency.self)]?() as? T
    }
    
    static func registerDependencies() {
        
        register(URLSession.self, URLSession.shared)
        register(NetworkClient.self, NetworkClient.shared)
        
        registerConfiguration()
        registerMoviesListDepndencies()
    }
    
    private static func registerConfiguration() {
        register(ConfigurationRemoteDataRepository.self, ConfigurationRemoteDataRepositoryImplementation())
        register(ConfigurationLocalDataRepository.self, ConfigurationLocalDataRepositoryImplementation())
        
        register(ConfigurationUseCase.self, ConfigurationUseCaseImplementation())
    }
    
    private static func registerMoviesListDepndencies() {
        register(MoviesRemoteDataRepository.self, MoviesRemoteDataRepositoryImplementation())
        register(MoviesLocalDataReposistory.self, MoviesLocalDataReposistoryImplementation())
        
        register(MoviesUseCase.self, MoviesUseCaseImplementaiton())
    }
}
