#include "hbclass.ch"
#include "fileio.ch"
#include "box.ch"

#include "functions.ch"

#define CONFIG_PATH 'config.cnf'

#define LIBCONFIG_VALUE 1
#define LIBCONFIG_VALIDATOR 2

#define NO_CONFIG_DEFAULT_DIALOG "There isn't the users's config file. Create it?"
#define NO_CONFIG_DEFAULT_INFORM "There isn't the user's config file. The program is going to be closed"

CREATE CLASS Config

EXPORTED:

    METHOD init_config(hUserConfig, cNoConfigFileDialog, cNoConfigFileInform)
    METHOD is_config(cKey, lLibConfig)
    METHOD get_config_hash(lLibConfig)
    METHOD get_config(cKey, lLibConfig) 

    METHOD save_config(cPath) INLINE ::create_config_file(::hUserConfig, cPath)
    METHOD set_config(cKey, xValue)

HIDDEN:

    METHOD handle_settings() INLINE ::handle_forms() .AND. ::handle_browse()
    METHOD create_forms_file()
    METHOD create_config_file(hConfig, cPath)
    METHOD create_browse_file()
    METHOD handle_user_config(hUserConfig, cNoConfigFileDialog, cNoConfigFileInform)
    METHOD handle_browse()
    METHOD handle_forms()
    METHOD validate_structure(axStructure, axPattern)
    METHOD validate_configs()

    CLASSVAR hUserConfig AS HASH INIT hb_Hash()
    CLASSVAR lSuccess AS LOGICAL INIT .F.
    CLASSVAR hLibConfig AS HASH INIT hb_Hash(;
                                            ; /*** WINDOW ***/
                                            'WindowUpperLeftCornerX', {0, {| xArgument |;
                                                                             ValType(xArgument) == 'N';
                                                                             .AND. Int(xArgument) == xArgument;
                                                                             .AND. xArgument >= 0;
                                                                          };
                                                                      };
                                            , 'WindowUpperLeftCornerY', {0, {| xArgument |;
                                                                             ValType(xArgument) == 'N';
                                                                             .AND. Int(xArgument) == xArgument;
                                                                             .AND. xArgument > 0;
                                                                          };
                                                                      };
                                            , 'WindowHeight', {MaxRow(), {| xArgument |;
                                                                             ValType(xArgument) == 'N';
                                                                             .AND. Int(xArgument) == xArgument;
                                                                             .AND. xArgument > 0;
                                                                             .AND. xArgument <= MaxRow();
                                                                          };
                                                                      };
                                            , 'WindowWidth', {MaxCol(), {| xArgument |;
                                                                             ValType(xArgument) == 'N';
                                                                             .AND. Int(xArgument) == 'N';
                                                                             .AND. Int(xArgument) == xArgument;
                                                                             .AND. xArgument > 0;
                                                                             .AND. xArgument <= MaxCol();
                                                                          };
                                                                      };
                                            , 'Title', {'', {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                          };
                                                                      };
                                            ; /*** PATHS ***/
                                            , 'FormsDefinitions', {'dbForms.dbf', {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. !Empty(xArgument);
                                                                          };
                                                                      };     
                                            , 'RowBrowseDefinitions', {'dbRowBrowse.dbf', {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. !Empty(xArgument);
                                                                          };
                                                                      };
                                            , 'dbfPath', {'', {| xArgument | ValType(xArgument) == 'C';
                                                                             .AND. !Empty(xArgument);
                                                                          };
                                                                      };
                                            , 'ntxPath', {'', {| xArgument | ValType(xArgument) == 'C';
                                                                             .AND. !Empty(xArgument);
                                                                          };
                                                                      };
                                            ; /*** BOXES ***/
                                            , 'RowBrowseDefaultBox', {HB_B_SINGLE_DOUBLE_UNI, {| xArgument |;
                                                                             is_box(xArgument);
                                                                          };
                                                                      };
                                            , 'ProgressBarDefaultBox', {HB_B_SINGLE_UNI, {| xArgument |;
                                                                             is_box(xArgument);
                                                                          };
                                                                      };
                                            , 'DefaultBox', {HB_B_DOUBLE_UNI, {| xArgument |;
                                                                             is_box(xArgument);
                                                                          };
                                                                      };    
                                            , 'WindowBorder', {HB_B_SINGLE_UNI, {| xArgument |;
                                                                             is_box(xArgument);
                                                                          };
                                                                      };
                                            ; /*** COLORS ***/
                                            , 'DefaultColor', {SetColor(), {| xArgument |;
                                                                             is_color(xArgument);
                                                                          };
                                                                      };
                                            , 'DefaultDialogColor', {'N/W,W+/N+', {| xArgument |;
                                                                             is_color(xArgument);
                                                                          };
                                                                      };
                                            , 'DefaultYesNoColor', {'N/W,W+/N+', {| xArgument |;
                                                                             is_color(xArgument);
                                                                          };
                                                                      };
                                            , 'DefaultInformColor', {'N/W,W+/N+', {| xArgument |;
                                                                             is_color(xArgument);
                                                                          };
                                                                      };
                                            , 'HeaderColor', {'N/GR,N/GR', {| xArgument |;
                                                                             is_color(xArgument);
                                                                          };
                                                                      };
                                            , 'FooterColor', {'N/R,R/N', {| xArgument |;
                                                                             is_color(xArgument);
                                                                          };
                                                                      };
                                            , 'TitleColor', {'B/N,N/B', {| xArgument |;
                                                                             is_color(xArgument);
                                                                          };
                                                                      };
                                            , 'BorderColor', {'R/G,G/R', {| xArgument |;
                                                                             is_color(xArgument);
                                                                          };
                                                                      };
                                            , 'DefaultMenuColor', {'N/W,W+/N+,R/B', {| xArgument |;
                                                                             is_color(xArgument);
                                                                          };
                                                                      };
                                            ; /*** ERRORS ***/
                                            , 'CantCreateConfigFile', {"Can't create the configuration file", {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. !Empty(xArgument);
                                                                          };
                                                                      };
                                            , 'WindowMustBeFirst', {'The window must be first', {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. !Empty(xArgument);
                                                                          };
                                                                      };
                                            , 'CorruptionDetected', {'A corruption was detected during a form parsing', {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. !Empty(xArgument);
                                                                          };
                                                                      };
                                            , 'VariableRepeating', {"Variable can't be repeated", {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. !Empty(xArgument);
                                                                          };
                                                                      };
                                            , 'IncorrectDataType', {'Incorrect data type', {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. !Empty(xArgument);
                                                                          };
                                                                      };
                                            , 'IncorrectValue', {'Incorrect value', {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. !Empty(xArgument);
                                                                          };
                                                                      };
                                            , 'IncorrectDimensions', {'Incorrect dimensions', {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. !Empty(xArgument);
                                                                          };
                                                                      };
                                            , 'EmptyObject', {'The object type field is empty', {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. !Empty(xArgument);
                                                                          };
                                                                      };
                                            , 'UnknownObject', {'Unknown object', {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. !Empty(xArgument);
                                                                          };
                                                                      };
                                            ; /*** MESSAGES ***/
                                            , 'DefaultPrintMessageOption', {'Ok', {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. !Empty(xArgument);
                                                                          };
                                                                      };
                                            , 'DefaultYes', {'Yes', {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. !Empty(xArgument);
                                                                          };
                                                                      };
                                            , 'DefaultNo', {'No', {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. !Empty(xArgument);
                                                                          };
                                                                      };
                                            , 'DefaultExit', {'Are you sure to exit?', {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. !Empty(xArgument);
                                                                          };
                                                                      };
                                            , 'NoBrowseFileDialog', {"There isn't the browse file. Create it?", {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. !Empty(xArgument);
                                                                          };
                                                                      };
                                            , 'NoBrowseFileInform', {"There isn't the browse file. The program is going to be closed", {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. !Empty(xArgument);
                                                                          };
                                                                      };
                                            , 'NoFormsFileDialog', {"There isn't the forms file. Create it?", {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. !Empty(xArgument);
                                                                          };
                                                                      };
                                            , 'NoFormsFileInform', {"There isn't the forms file. The program is going to be closed", {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. !Empty(xArgument);
                                                                          };
                                                                      };
                                            ; /*** PROGRESSBAR ***/
                                            , 'ProgressBarFirstCharacter', {'[', {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. Len(xArgument) == 1;
                                                                          };
                                                                      };
                                            , 'ProgressBarLastCharacter', {']', {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. Len(xArgument) == 1;
                                                                          };
                                                                      };
                                            , 'ProgressBarEmptyCharacter', {' ', {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. Len(xArgument) == 1;
                                                                          };
                                                                      };
                                            , 'ProgressBarFilledCharacter', {'#', {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. Len(xArgument) == 1;
                                                                          };
                                                                      };
                                            , 'ProgressBarFinishedCharacter', {'@', {| xArgument |;
                                                                             ValType(xArgument) == 'C';
                                                                             .AND. Len(xArgument) == 1;
                                                                          };
                                                                      };
                                            )
    CLASSVAR axFormsStructure AS ARRAY INIT {;
                                            {'ID', 'C', 50, 0};
                                            , {'LANGUAGE', 'C', 30, 0};
                                            , {'CODE', 'M', 10, 0};
                                            }
    CLASSVAR axRowBrowseStructure AS ARRAY INIT {;
                                            {'ID', 'C', 100, 0};
                                            , {'COL_NR', 'N', 3, 0};
                                            , {'WIDTH', 'N', 3, 0};
                                            , {'RELATIVE', 'L', 1, 0};
                                            , {'FLD_SEP', 'C', 2, 0};
                                            , {'FLD_ALIGN', 'C', 1, 0};
                                            , {'HEAD', 'C', 150, 0};
                                            , {'HEAD_SEP', 'C', 2, 0};
                                            , {'HEAD_ALIGN', 'C', 1, 0};
                                            , {'PRINT', 'M', 10, 0};
                                            }

ENDCLASS LOCK

METHOD set_config(cKey, xValue) CLASS Config

    assert_type(cKey, 'C')

    IF PCount() != 2
        throw(RUNTIME_EXCEPTION)
    ENDIF

    IF hb_hHasKey(::hUserConfig, cKey)
        IF hb_hHasKey(::hLibConfig, cKey)
            IF !Eval(::hLibConfig[cKey][LIBCONFIG_VALIDATOR], xValue)
                throw(RUNTIME_EXCEPTION)
            ENDIF
        ENDIF
        ::hUserConfig[cKey] := xValue
    ELSE
        throw(RUNTIME_EXCEPTION)
    ENDIF

RETURN NIL

METHOD is_config(cKey, lLibConfig) CLASS Config

    assert_type(cKey, 'C')

    IF ValType(lLibConfig) == 'L'
        IF lLibConfig
            RETURN hb_hHasKey(::hLibConfig, cKey)
        ELSE
            RETURN hb_hHasKey(::hUserConfig, cKey)
        ENDIF
    ENDIF

RETURN hb_hHasKey(::hUserConfig, cKey) .OR. hb_hHasKey(::hLibConfig, cKey)

METHOD get_config(cKey, lLibConfig) CLASS Config

    IF ValType(lLibConfig) == 'L'
        IF lLibConfig
            IF hb_hHasKey(::hLibConfig, cKey)
                RETURN ::hLibConfig[cKey][LIBCONFIG_VALUE]
            ELSE
                throw(RUNTIME_EXCEPTION)
            ENDIF
        ELSE
            IF hb_hHasKey(::hUserConfig, cKey)
                RETURN ::hUserConfig[cKey]
            ELSE
                throw(RUNTIME_EXCEPTION)
            ENDIF
        ENDIF
    ELSE
        IF hb_hHasKey(::hUserConfig, cKey)
            RETURN ::hUserConfig[cKey]
        ELSEIF hb_hHasKey(::hLibConfig, cKey)
            RETURN ::hLibConfig[cKey][LIBCONFIG_VALUE]
        ELSE
            //Alert(cKey) //debug 
            throw(ARGUMENT_VALUE_EXCEPTION)
        ENDIF
    ENDIF

RETURN NIL

METHOD get_config_hash(lLibConfig) CLASS Config

    IF ValType(lLibConfig) == 'L'
        IF lLibConfig
            RETURN hb_hClone(::hLibConfig)
        ELSE
            RETURN hb_hClone(::hUserConfig)
        ENDIF
    ENDIF

RETURN hb_hClone(::hUserConfig)

METHOD init_config(hUserConfig, cNoConfigFileDialog, cNoConfigFileInform) CLASS Config

    LOCAL nOldSelect := Select()

    IF cNoConfigFileDialog != NIL
        assert_type(cNoConfigFileDialog, 'C')
    ENDIF

    IF cNoConfigFileInform != NIL
        assert_type(cNoConfigFileInform, 'C')
    ENDIF

    IF !::lSuccess
        ::lSuccess := ::handle_user_config(hUserConfig, cNoConfigFileDialog, cNoConfigFileInform) .AND. ::handle_settings() 
    ENDIF

    SELECT (nOldSelect)

RETURN ::lSuccess

METHOD handle_browse() CLASS Config

    LOCAL cNoBrowseFileDialog := Config():get_config('NoBrowseFileDialog')
    LOCAL cNoBrowseFileInform := Config():get_config('NoBrowseFileInform')
    LOCAL lSuccess

    IF File(::get_config('dbfPath') + ::get_config('RowBrowseDefinitions'))
        USE (::get_config('dbfPath') + ::get_config('RowBrowseDefinitions')) VIA 'DBFNTX' ALIAS dbRowBrowse NEW EXCLUSIVE
        lSuccess := (Alias() == 'DBROWBROWSE') .AND. ::validate_structure(dbStruct(), ::axRowBrowseStructure)
    ELSE
        IF YesNo(cNoBrowseFileDialog)
            lSuccess := ::create_browse_file()
        ELSE
            Inform(cNoBrowseFileInform)
            lSuccess := .F.
        ENDIF
    ENDIF

    IF lSuccess
        INDEX ON field->id + Str(field->col_nr) TO (::get_config('ntxPath') + 'browse')
    ENDIF

RETURN lSuccess

METHOD handle_user_config(hUserConfig, cNoConfigFileDialog, cNoConfigFileInform) CLASS Config

    LOCAL lSuccess := .T.

    IF Empty(cNoConfigFileDialog)
        cNoConfigFileDialog := NO_CONFIG_DEFAULT_DIALOG
    ENDIF

    IF Empty(cNoConfigFileInform)
        cNoConfigFileInform := NO_CONFIG_DEFAULT_INFORM
    ENDIF

    IF !File(CONFIG_PATH)
        IF YesNo(cNoConfigFileDialog, , , .T.)
            lSuccess := ::create_config_file(hUserConfig)
            IF !lSuccess
                Inform(cNoConfigFileInform, , , , .T.)
            ENDIF
        ELSE
            Inform(cNoConfigFileInform, , , , .T.)
            lSuccess := .F.
        ENDIF
    ENDIF

    IF lSuccess
        hb_JsonDecode(MemoRead(CONFIG_PATH), @::hUserConfig)
    ENDIF

RETURN lSuccess .AND. ::validate_configs()

METHOD handle_forms()

    LOCAL cNoFormsFileDialog := Config():get_config('NoFormsFileDialog')
    LOCAL cNoFormsFileInform := Config():get_config('NoFormsFileInform')
    LOCAL lSuccess

    IF File(::get_config('dbfPath') + ::get_config('FormsDefinitions'))
        USE (::get_config('dbfPath') + ::get_config('FormsDefinitions')) VIA 'DBFNTX' ALIAS dbForms NEW EXCLUSIVE 
        lSuccess := (Alias() == 'DBFORMS') .AND. ::validate_structure(dbStruct(), ::axFormsStructure)
    ELSE
        IF YesNo(cNoFormsFileDialog)
            lSuccess := ::create_forms_file()
            IF !lSuccess
                Inform(cNoFormsFileInform)
            ENDIF
        ELSE
            Inform(cNoFormsFileInform)
            lSuccess := .F.
        ENDIF
    ENDIF

    IF lSuccess
        INDEX ON field->language + field->id TO (::get_config('ntxPath') + 'dbFormsInd1')
    ENDIF

RETURN lSuccess


METHOD validate_structure(axStructure, axPattern) CLASS Config

    LOCAL i, j

    IF Len(axStructure) != Len(axPattern)
        RETURN .F.
    ENDIF

    FOR i = 1 TO Len(axStructure)
        IF ValType(axStructure[i]) != 'A' .OR. Len(axStructure[i]) != 4
            RETURN .F.
        ENDIF

        FOR j = 1 TO 4
            IF axStructure[i][j] != axPattern[i][j]
                RETURN .F.
            ENDIF
        NEXT
    NEXT

RETURN .T.

METHOD create_browse_file() CLASS Config

    dbCreate(::get_config('dbfPath') + ::get_config('RowBrowseDefinitions'), ::axRowBrowseStructure, 'DBFNTX', .T., 'dbRowBrowse')

RETURN Alias() == 'DBROWBROWSE'

METHOD create_forms_file() CLASS Config

    dbCreate(::get_config('dbfPath') + ::get_config('FormsDefinitions'), ::axFormsStructure, 'DBFNTX', .T., 'dbForms')

RETURN Alias() == 'DBFORMS'

METHOD create_config_file(hConfig, cPath) CLASS Config

    LOCAL lSuccess := .F.
    LOCAL xWasPrinter := Set(_SET_PRINTER)
    LOCAL xWasPrinterFile := Set(_SET_PRINTFILE)
    LOCAL xWasConsole := Set(_SET_CONSOLE)
    LOCAL nHandler

    IF cPath != NIL
        assert_type(cPath, 'C')
    ELSE
        cPath = CONFIG_PATH
    ENDIF

    nHandler := FCreate(cPath, FC_NORMAL)

    IF nHandler != -1
        SET PRINTER TO (cPath)
        SET PRINTER ON
        SET CONSOLE OFF
        ? hb_JsonEncode(hConfig, .T.)
        Set(_SET_PRINTER, xWasPrinter)
        Set(_SET_PRINTFILE, xWasPrinterFile)
        Set(_SET_CONSOLE, xWasConsole)
        //SET PRINTER TO
        //SET PRINTER OFF 
        //SET CONSOLE ON
        lSuccess := .T.
    ELSE
        Inform(Config():get_config('CantCreateConfigFile'), , , , .T.)
    ENDIF

    FClose(nHandler)

RETURN lSuccess

METHOD validate_configs() CLASS Config

    LOCAL acLibKeys := hb_hKeys(::hLibConfig)
    LOCAL cKey

    FOR EACH cKey IN acLibKeys
        IF hb_hHasKey(::hUserConfig, cKey)
            IF !Eval(::hLibConfig[cKey][LIBCONFIG_VALIDATOR], ::hUserConfig[cKey], ::hLibConfig)
                RETURN .F.
            ENDIF
        ENDIF
    NEXT

RETURN .T.
