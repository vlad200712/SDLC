// Библиотека элементов интерфейса для макетов и контекстной диаграммы AutoService.
// Координаты и размеры задаются в пикселях относительно родительского элемента.
package UiLibrary {
    private import ScalarValues::*;

    part def UiElement {
        attribute posX : Integer;
        attribute posY : Integer;
        attribute width : Integer;
        attribute height : Integer;
        attribute caption : String;
        attribute subcaption : String;
        attribute tone : String;
    }

    part def Screen :> UiElement;
    part def Panel :> UiElement;
    part def Card :> UiElement;
    part def Heading :> UiElement;
    part def Label :> UiElement;
    part def Mono :> UiElement;
    part def TextField :> UiElement;
    part def Button :> UiElement;
    part def PrimaryButton :> Button;
    part def SuccessButton :> Button;
    part def DangerButton :> Button;
    part def WarningButton :> Button;
    part def TabActive :> UiElement;
    part def TabInactive :> UiElement;
    part def Badge :> UiElement;
    part def CheckRow :> UiElement;
    part def SlotChip :> UiElement;
    part def ProgressBar :> UiElement {
        attribute progress : Integer;
        attribute steps : String;
    }
    part def ListRow :> UiElement;
    part def Table :> UiElement {
        attribute columns : String;
        attribute columnWidths : String;
    }
    part def TableRow :> UiElement {
        attribute cells : String;
    }
    part def Block :> UiElement;
    part def Actor :> UiElement;

    connection def Link {
        attribute caption : String;
        end endA : UiElement;
        end endB : UiElement;
    }
}
