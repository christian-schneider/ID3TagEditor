//
//  ID3FrameContentSizeParserTest.swift
//
//  Created by Fabrizio Duroni on 23/02/2018.
//  2018 Fabrizio Duroni.
//

import XCTest
@testable import ID3TagEditor

class ID3TagEditorTest: XCTestCase {
    let id3TagEditor = ID3TagEditor()

    func testFailWrongFilePathFilePath() {
        XCTAssertThrowsError(try id3TagEditor.read(from: "::a wrong path::"))
        XCTAssertThrowsError(try id3TagEditor.write(tag: ID3Tag(version: .version2, size: 0), to: ""))
    }
    
    func testReadTagV2() {
        let path = PathLoader().pathFor(name: "example-cover", fileType: "jpg")
        let cover = try! Data(contentsOf: URL(fileURLWithPath: path))

        let id3Tag = try! id3TagEditor.read(from: PathLoader().pathFor(name: "example", fileType: "mp3"))

        XCTAssertEqual(id3Tag?.properties.version, .version2)
        XCTAssertEqual(id3Tag?.title, "example song")
        XCTAssertEqual(id3Tag?.album, "example album")
        XCTAssertEqual(id3Tag?.albumArtist, "example album artist")
        XCTAssertEqual(id3Tag?.artist, "example artist")
        XCTAssertEqual(id3Tag?.attachedPictures?[0].art, cover)
    }
    
    func testWriteTagV2() {
        let art: Data = try! Data(
            contentsOf: URL(fileURLWithPath: PathLoader().pathFor(name: "example-cover", fileType: "jpg"))
        )
        let pathMp3ToCompare = PathLoader().pathFor(name: "example", fileType: "mp3")
        let pathMp3Generated = NSHomeDirectory() + "/example-v2.mp3"
        let id3Tag = ID3Tag(
            version: .version2,
            artist: "example artist",
            albumArtist: "example album artist",
            album: "example album",
            title: "example song",
            year: nil,
            genre: nil,
            attachedPictures: [AttachedPicture(art: art, type: .FrontCover, format: .Jpeg)],
            trackPosition: nil
        )
        
        XCTAssertNoThrow(try id3TagEditor.write(
            tag: id3Tag,
            to: PathLoader().pathFor(name: "example", fileType: "mp3"),
            andSaveTo: pathMp3Generated
        ))
        XCTAssertEqual(
            try! Data(contentsOf: URL(fileURLWithPath: pathMp3Generated)),
            try! Data(contentsOf: URL(fileURLWithPath: pathMp3ToCompare))
        )
    }

    func testParseTagV3() {
        let path = PathLoader().pathFor(name: "example-cover-png", fileType: "png")
        let cover = try! Data(contentsOf: URL(fileURLWithPath: path))

        let id3Tag = try! id3TagEditor.read(from: PathLoader().pathFor(name: "example-v23-png", fileType: "mp3"))

        XCTAssertEqual(id3Tag?.properties.version, .version3)
        XCTAssertEqual(id3Tag?.title, "A New title")
        XCTAssertEqual(id3Tag?.album, "A New Album")
        XCTAssertEqual(id3Tag?.artist, "A New Artist")
        XCTAssertEqual(id3Tag?.attachedPictures?[0].art, cover)
        XCTAssertEqual(id3Tag?.attachedPictures?[0].format, .Png)
    }

    func testParseTagV3AdditionalData() {
        let pathFront = PathLoader().pathFor(name: "example-cover", fileType: "jpg")
        let pathBack = PathLoader().pathFor(name: "cover2", fileType: "jpg")
        let coverFront = try! Data(contentsOf: URL(fileURLWithPath: pathFront))
        let coverBack = try! Data(contentsOf: URL(fileURLWithPath: pathBack))

        let id3Tag = try! id3TagEditor.read(from: PathLoader().pathFor(name: "example-v3-additional-data", fileType: "mp3"))

        XCTAssertEqual(id3Tag?.properties.version, .version3)
        XCTAssertEqual(id3Tag?.title, "A New title")
        XCTAssertEqual(id3Tag?.album, "A New Album")
        XCTAssertEqual(id3Tag?.artist, "A New Artist")
        XCTAssertEqual(id3Tag?.albumArtist, "A New Album Artist")
        XCTAssertEqual(id3Tag?.attachedPictures?[0].art, coverFront)
        XCTAssertEqual(id3Tag?.attachedPictures?[0].format, .Jpeg)
        XCTAssertEqual(id3Tag?.attachedPictures?[0].type, .FrontCover)
        XCTAssertEqual(id3Tag?.attachedPictures?[1].art, coverBack)
        XCTAssertEqual(id3Tag?.attachedPictures?[1].format, .Jpeg)
        XCTAssertEqual(id3Tag?.attachedPictures?[1].type, .BackCover)
        XCTAssertEqual(id3Tag?.genre?.identifier, .Metal)
        XCTAssertEqual(id3Tag?.genre?.description, "Metalcore")
        XCTAssertEqual(id3Tag?.year, "2018")
        XCTAssertEqual(id3Tag?.trackPosition?.position, 2)
        XCTAssertEqual(id3Tag?.trackPosition?.totalTracks, 9)
    }

    func testWriteTagWhenItAlreadyExists() {
        let art: Data = try! Data(
                contentsOf: URL(fileURLWithPath: PathLoader().pathFor(name: "example-cover", fileType: "jpg"))
        )
        let pathMp3ToCompare = PathLoader().pathFor(name: "example-with-tag-jpg-v3", fileType: "mp3")
        let pathMp3Generated = NSHomeDirectory() + "/example-tag-already-exists.mp3"
        let id3Tag = ID3Tag(
                version: .version3,
                artist: "A New Artist",
                albumArtist: "A New Album Artist",
                album: "A New Album",
                title: "A New title",
                year: nil,
                genre: nil,
                attachedPictures: [AttachedPicture(art: art, type: .FrontCover, format: .Jpeg)],
                trackPosition: nil
        )

        XCTAssertNoThrow(try id3TagEditor.write(
                tag: id3Tag,
                to: PathLoader().pathFor(name: "example-with-tag-already-setted", fileType: "mp3"),
                andSaveTo: pathMp3Generated
        ))

        XCTAssertEqual(
                try! Data(contentsOf: URL(fileURLWithPath: pathMp3Generated)),
                try! Data(contentsOf: URL(fileURLWithPath: pathMp3ToCompare))
        )
    }

    func testWriteTagWithJpg() {
        let art: Data = try! Data(
                contentsOf: URL(fileURLWithPath: PathLoader().pathFor(name: "example-cover", fileType: "jpg"))
        )
        let pathMp3ToCompare = PathLoader().pathFor(name: "example-with-tag-jpg-v3", fileType: "mp3")
        let pathMp3Generated = NSHomeDirectory() + "/example-v3-jpg.mp3"
        let id3Tag = ID3Tag(
                version: .version3,
                artist: "A New Artist",
                albumArtist: "A New Album Artist", ///2
                album: "A New Album",
                title: "A New title",
                year: nil,
                genre: nil,
                attachedPictures: [AttachedPicture(art: art, type: .FrontCover, format: .Jpeg)],
                trackPosition: nil
        )

        XCTAssertNoThrow(try id3TagEditor.write(
                tag: id3Tag,
                to: PathLoader().pathFor(name: "example-to-be-modified", fileType: "mp3"),
                andSaveTo: pathMp3Generated
        ))
        XCTAssertEqual(
                try! Data(contentsOf: URL(fileURLWithPath: pathMp3Generated)),
                try! Data(contentsOf: URL(fileURLWithPath: pathMp3ToCompare))
        )
    }
    
    func testWriteTagWithPng() {
        let art: Data = try! Data(
            contentsOf: URL(fileURLWithPath: PathLoader().pathFor(name: "example-cover-png", fileType: "png"))
        )
        let id3Tag = ID3Tag(
                version: .version3,
                artist: "A New Artist",
                albumArtist: "A New Album Artist",
                album: "A New Album",
                title: "A New title",
                year: nil,
                genre: nil,
                attachedPictures: [AttachedPicture(art: art, type: .FrontCover, format: .Png)],
                trackPosition: nil
        )

        XCTAssertNoThrow(try id3TagEditor.write(
                tag: id3Tag,
                to: PathLoader().pathFor(name: "example-to-be-modified", fileType: "mp3"),
                andSaveTo: NSHomeDirectory() + "/example-v3-png.mp3"
        ))
    }

    func testWriteTagWithCustomPathThatDoesNotExists() {
        let art: Data = try! Data(
                contentsOf: URL(fileURLWithPath: PathLoader().pathFor(name: "example-cover", fileType: "jpg"))
        )
        let pathMp3Generated = NSHomeDirectory() + "/ID3TagEditor/example-v3-custom-path.mp3"
        let id3Tag = ID3Tag(
                version: .version3,
                artist: "A New Artist",
                albumArtist: "A New Album Artist",
                album: "A New Album",
                title: "A New title",
                year: nil,
                genre: nil,
                attachedPictures: [AttachedPicture(art: art, type: .FrontCover, format: .Jpeg)],
                trackPosition: nil
        )

        XCTAssertNoThrow(try id3TagEditor.write(
                tag: id3Tag,
                to: PathLoader().pathFor(name: "example-to-be-modified", fileType: "mp3"),
                andSaveTo: pathMp3Generated
        ))
    }

    func testWriteTagWithSamePath() {
        let art: Data = try! Data(
                contentsOf: URL(fileURLWithPath: PathLoader().pathFor(name: "example-cover", fileType: "jpg"))
        )
        let id3Tag = ID3Tag(
                version: .version3,
                artist: "A New Artist",
                albumArtist: "A New Album Artist",
                album: "A New Album",
                title: "A New title",
                year: nil,
                genre: nil,
                attachedPictures: [AttachedPicture(art: art, type: .FrontCover, format: .Jpeg)],
                trackPosition: nil
        )

        XCTAssertNoThrow(try id3TagEditor.write(
                tag: id3Tag,
                to: PathLoader().pathFor(name: "example-to-be-modified-in-same-path", fileType: "mp3")
        ))
    }

    func testWriteTagWithAdditionalData() {
        let artFront: Data = try! Data(
                contentsOf: URL(fileURLWithPath: PathLoader().pathFor(name: "example-cover", fileType: "jpg"))
        )
        let artBack: Data = try! Data(
                contentsOf: URL(fileURLWithPath: PathLoader().pathFor(name: "cover2", fileType: "jpg"))
        )
        let pathMp3ToCompare = PathLoader().pathFor(name: "example-v3-additional-data", fileType: "mp3")
        let pathMp3Generated = NSHomeDirectory() + "/example-v3-additional-data.mp3"
        let id3Tag = ID3Tag(
                version: .version3,
                artist: "A New Artist",
                albumArtist: "A New Album Artist",
                album: "A New Album",
                title: "A New title",
                year: "2018",
                genre: Genre(genre: .Metal, description: "Metalcore"),
                attachedPictures: [
                    AttachedPicture(art: artFront, type: .FrontCover, format: .Jpeg),
                    AttachedPicture(art: artBack, type: .BackCover, format: .Jpeg)
                ],
                trackPosition: TrackPositionInSet(position: 2, totalTracks: 9)
        )

        XCTAssertNoThrow(try id3TagEditor.write(
                tag: id3Tag,
                to: PathLoader().pathFor(name: "example-to-be-modified", fileType: "mp3"),
                andSaveTo: NSHomeDirectory() + "/example-v3-additional-data.mp3"
        ))
        XCTAssertEqual(
                try! Data(contentsOf: URL(fileURLWithPath: pathMp3Generated)),
                try! Data(contentsOf: URL(fileURLWithPath: pathMp3ToCompare))
        )
    }

    func testUtf16String() {
        let id3TagEditor = ID3TagEditor()
        let pathMp3 = PathLoader().pathFor(name: "example-utf16", fileType: "mp3")
        
        let id3Tag = try! id3TagEditor.read(from: pathMp3)
        
        XCTAssertEqual(id3Tag?.title, "Om Tryumbacom")
        XCTAssertEqual(id3Tag?.artist, "Laraaji")
        XCTAssertEqual(id3Tag?.album, "Vision Songs Vol. 1")
        XCTAssertEqual(id3Tag?.year, "2018")
        XCTAssertEqual(id3Tag?.trackPosition?.position, 10)
    }
}
