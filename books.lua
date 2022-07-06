CUA_books.book_item_id = false
local book_text_font = "Interface\\AddOns\\ClassicUA\\assets\\Morpheus_UA.ttf"

local book_frame = nil
local function get_book_frame()
    if book_frame then
        return book_frame
    end

    local width, height = ItemTextFrame:GetSize()
    local frame = CreateFrame("frame", nil, ItemTextFrame, "BackdropTemplate")
    frame:SetFrameStrata("HIGH")
    frame:SetSize(width - 64, height - 160)
    frame:SetPoint("TOP", 0, -72)
    frame:SetPoint("RIGHT", frame:GetWidth() - 37, 0)

    CUA_frames:setup_frame_background_and_border(frame)

    CUA_frames:setup_frame_scrollbar_and_content(frame, { -- todo: take book font size from config
        text = { book_text_font, 15 }
    })

    frame:Show()

    book_frame = frame
    return book_frame
end

local function set_book_content(text)
    local f = get_book_frame()
    local h = 16

    f.text:SetPoint("TOPLEFT", f.content, 12, -h)
    f.text:SetText(text)
    h = h + f.text:GetHeight() + 12

    CUA_frames:setup_frame_scrollbar_values(f, h)
end

function CUA_books:show_book()
    local book = get_entry("book", CUA_books.book_item_id)
    if book then
        local page = ItemTextGetPage()
        if not book[page] and book[1] then
            book[page] = book[1]
        end
        set_book_content(book[page])
        get_book_frame():Show()
    end
end

function CUA_books:hide_book()
    get_book_frame():Hide()
    CUA_books.book_item_id = false
end
