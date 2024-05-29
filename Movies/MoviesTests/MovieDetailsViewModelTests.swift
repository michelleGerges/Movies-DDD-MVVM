//
//  MovieDetailsViewModelTests.swift
//  MoviesTests
//
//  Created by Michelle on 29/05/2024.
//

import XCTest
import Combine

@testable import Movies

final class MovieDetailsViewModelTests: XCTestCase {
    var viewModel: MovieDetailsViewModel!
    var mockUseCase: MockMovieDetialsUseCase!
    var mockConfigurationUseCase: MockConfigurationUseCase!
    var subscriptions = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        mockUseCase = MockMovieDetialsUseCase()
        mockConfigurationUseCase = MockConfigurationUseCase()
        
        DependencyContainer.register(MovieDetialsUseCase.self, self.mockUseCase)
        DependencyContainer.register(ConfigurationUseCase.self, self.mockConfigurationUseCase)
        
        viewModel = MovieDetailsViewModel(movieID: 123)
    }
    
    override func tearDown() {
        viewModel = nil
        mockUseCase = nil
        mockConfigurationUseCase = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertTrue(viewModel.movieDetailsViewModels.isEmpty)
        XCTAssertNil(viewModel.movieTitle)
        XCTAssertNil(viewModel.loadMovieDetailsError)
    }
    
    func testLoadMovieDetailsSuccess() {
        let movieDetails = MovieDetails(budget: 1000000, genres: [Genre(id: 1, name: "Action")], overview: "This is a test movie", posterPath: "/test.jpg", runtime: 120, title: "Test Movie")
        mockUseCase.movieDetails = movieDetails
        let expectation = XCTestExpectation(description: "Movie details loaded")
        
        viewModel
            .$movieDetailsViewModels
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        viewModel.loadMovieDetilas()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.movieDetailsViewModels.count, 5)
        XCTAssertEqual(viewModel.movieTitle, "Test Movie")
        XCTAssertNil(viewModel.loadMovieDetailsError)
        XCTAssertFalse(viewModel.isEmpty)
    }
    
    func testLoadMovieDetailsTitle() {
        let movieDetails = MovieDetails(title: "Test Movie")
        mockUseCase.movieDetails = movieDetails
        let expectation = XCTestExpectation(description: "Movie title loaded")
        
        viewModel
            .$movieTitle
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        viewModel.loadMovieDetilas()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.movieTitle, "Test Movie")
    }
    
    func testLoadMovieDetailsFailure() {
        mockUseCase.error = NSError(domain: "", code: -1, userInfo: nil)
        let expectation = XCTestExpectation(description: "Movie details failed to load")
        
        viewModel
            .$loadMovieDetailsError
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        viewModel.loadMovieDetilas()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(viewModel.loadMovieDetailsError)
        XCTAssertTrue(viewModel.isEmpty)
    }
    
    func testNumberOfSections() {
        XCTAssertEqual(1, viewModel.numberOfSections)
    }
    
    func testNumberOfRowsInSection() {
        let movieDetails = MovieDetails(budget: 1000000, genres: [Genre(id: 1, name: "Action")], overview: "This is a test movie", posterPath: "/test.jpg", runtime: 120)
        mockUseCase.movieDetails = movieDetails
        let expectation = XCTestExpectation(description: "Movie details loaded")
        
        viewModel
            .$movieDetailsViewModels
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        viewModel.loadMovieDetilas()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.numberOfRowsInSection(0), 5)
    }
    
    func testMovieDetailsCellViewModelAt() {
        let movieDetails = MovieDetails(budget: 1000000, genres: [Genre(id: 1, name: "Action")], overview: "This is a test movie", posterPath: "/test.jpg", runtime: 120)
        mockUseCase.movieDetails = movieDetails
        let expectation = XCTestExpectation(description: "Movie details loaded")
        
        viewModel
            .$movieDetailsViewModels
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        viewModel.loadMovieDetilas()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(viewModel.movieDetailsCellViewModelAt(IndexPath(row: 0, section: 0)) as? MovieDetailsImageCellViewModel)
        XCTAssertNotNil(viewModel.movieDetailsCellViewModelAt(IndexPath(row: 1, section: 0)) as? MovieDetailsDescriptionCellViewModel)
        XCTAssertNotNil(viewModel.movieDetailsCellViewModelAt(IndexPath(row: 2, section: 0)) as? MovieDetailsTitleValueCellViewModel)
        XCTAssertNotNil(viewModel.movieDetailsCellViewModelAt(IndexPath(row: 3, section: 0)) as? MovieDetailsTitleValueCellViewModel)
    }
    
    func testMakeMovieDetailsPosterCell() {
        let movieDetails = MovieDetails(posterPath: "/poster1.jpg")
        let cellViewModel = viewModel.makeMovieDetailsPosterCell(movieDetails) as? MovieDetailsImageCellViewModel
        XCTAssertNotNil(cellViewModel)
        XCTAssertEqual(cellViewModel?.imageURL.absoluteString, "https://example.com/original/poster1.jpg")
    }
    
    func testMakeMovieDetailsOverviewCell() {
        let movieDetails = MovieDetails(overview: "This is the overview")
        let cellViewModel = viewModel.makeMovieDetailsOverviewCell(movieDetails) as? MovieDetailsDescriptionCellViewModel
        XCTAssertNotNil(cellViewModel)
        XCTAssertEqual(cellViewModel?.description, "This is the overview")
    }
    
    func testMakeMovieDetailsGenresCell() {
        let movieDetails = MovieDetails(genres: [Genre(id: 1, name: "Action"), Genre(id: 2, name: "Drama")])
        let cellViewModel = viewModel.makeMovieDetailsGenresCell(movieDetails) as? MovieDetailsTitleValueCellViewModel
        XCTAssertNotNil(cellViewModel)
        XCTAssertEqual(cellViewModel?.title, "Genres")
        XCTAssertEqual(cellViewModel?.value, "Action, Drama")
    }
    
    func testMakeMovieDetailsGenresCellNilWhenEmptyGenres() {
        let movieDetails = MovieDetails(genres: [])
        let cellViewModel = viewModel.makeMovieDetailsGenresCell(movieDetails) as? MovieDetailsTitleValueCellViewModel
        XCTAssertNil(cellViewModel)
    }
    
    func testMakeMovieDetailsBudgetCell() {
        let movieDetails = MovieDetails(budget: 1000000)
        let cellViewModel = viewModel.makeMovieDetailsBudgetCell(movieDetails) as? MovieDetailsTitleValueCellViewModel
        XCTAssertNotNil(cellViewModel)
        XCTAssertEqual(cellViewModel?.title, "Budget")
        XCTAssertEqual(cellViewModel?.value, "US$1,000,000.00")
    }
    
    func testMakeMovieDetailsRuntimeCell() {
        let movieDetails = MovieDetails(runtime: 120)
        let cellViewModel = viewModel.makeMovieDetailsRuntimeCell(movieDetails) as? MovieDetailsTitleValueCellViewModel
        XCTAssertNotNil(cellViewModel)
        XCTAssertEqual(cellViewModel?.title, "Runtime")
        XCTAssertEqual(cellViewModel?.value, "2 hours")
    }

}

extension MovieDetailsViewModelTests {
    class MockMovieDetialsUseCase: MovieDetialsUseCase {
        
        var movieDetails: MovieDetails?
        var error: Error?
        
        func loadMovieDetials(_ movieID: Int) -> AnyPublisher<MovieDetails, Error> {
            
            if let error = error {
                return Fail(error: error).eraseToAnyPublisher()
            } else if let movieDetails = movieDetails {
                return Just(movieDetails)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } else {
                fatalError("No mock data provided")
            }
        }
    }
    
    class MockConfigurationUseCase: ConfigurationUseCase {
        func loadConfiguration() -> AnyPublisher<Movies.Configuration, any Error> {
            Future<Configuration, Error>({ _ in }).eraseToAnyPublisher()
        }
        
        var configuration: Configuration? = Configuration(images: ImagesConfig(baseUrl: "https://example.com", posterSizes: ["w500", "original"]))
    }
}
