//
//  PDFListObject.swift
//  TPPDF
//
//  Created by Philip Niedertscheider on 12/08/2017.
//

/**
 TODO: documentation
 */
class PDFListObject: PDFObject {

    /**
     TODO: documentation
     */
    var list: PDFList

    /**
     TODO: documentation
     */
    init(list: PDFList) {
        self.list = list
    }

    /**
     TODO: documentation
     */
    override func calculate(generator: PDFGenerator, container: PDFContainer) throws -> [(PDFContainer, PDFObject)] {
        var result: [(PDFContainer, PDFObject)] = []

        let originalLeftIndent = generator.layout.indentation.leftIn(container: container)

        for item in list.flatted() {
            let indent = item.level < list.levelIndentations.count ?
                list.levelIndentations[item.level] :
                list.levelIndentations.last ?? (pre: 0, past: 0)

            generator.layout.indentation.setLeft(indentation: originalLeftIndent + indent.pre, in: container)
            result += try createSymbolItem(generator: generator, container: container, symbol: item.symbol)

            generator.layout.indentation.setLeft(indentation: originalLeftIndent + indent.pre + indent.past, in: container)
            result += try createTextItem(generator: generator, container: container, text: item.text)

            generator.layout.indentation.setLeft(indentation: originalLeftIndent, in: container)
        }

        return result
    }

    private func createSymbolItem(generator: PDFGenerator, container: PDFContainer, symbol: PDFListItemSymbol) throws -> [(PDFContainer, PDFObject)] {
        let symbol: String = symbol.stringValue
        let symbolText = PDFSimpleText(text: symbol)
        let symbolTextObject = PDFAttributedTextObject(simpleText: symbolText)
        let toAdd = try symbolTextObject.calculate(generator: generator, container: container)

        if toAdd.count > 0 {
            let symbolTextElement = (toAdd.count > 1 && toAdd[0].1 is PDFPageBreakObject) ? toAdd[1].1 : toAdd[0].1
            let offset = PDFCalculations.calculateContentOffset(for: generator, of: symbolTextElement, in: container)
            generator.setContentOffset(in: container, to: offset)

            return toAdd
        }
        return []
    }

    private func createTextItem(generator: PDFGenerator, container: PDFContainer, text: String) throws -> [(PDFContainer, PDFObject)] {
        let itemText = PDFSimpleText(text: text)
        let itemTextObject = PDFAttributedTextObject(simpleText: itemText)
        return try itemTextObject.calculate(generator: generator, container: container)
    }

    /**
     Creates a new `PDFListObject` with the same properties
     */
    override var copy: PDFObject {
        return PDFListObject(list: self.list.copy)
    }
}
