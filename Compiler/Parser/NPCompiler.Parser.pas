﻿unit NPCompiler.Parser;

interface

{$i compilers.inc}

uses iDStringParser, SysUtils, Classes, NPCompiler.Classes, NPCompiler.Errors;

type

  TTokenID = (
    token_unknown {= -1},           // unknown token
    token_eof {= 0},                // end of file
    token_identifier,               // some id

    token_numbersign,               // #
    token_semicolon,                // ;
    token_colon,                    // :

    token_assign,                   // :=
    token_equal,                    // =
    token_above,                    // >
    token_aboveorequal,             // >=
    token_less,                     // <
    token_lessorequal,              // <=
    token_notequal,                 // <>
    token_period,                   // ..
    token_lambda,                   // ~
    token_plusplus,                 // ++
    token_minusminus,               // --

    token_exclamation,              // !
    token_question,                 // ?

    token_plus,                     // +
    token_minus,                    // -
    token_asterisk,                 // *
    token_slash,                    // /
    token_caret,                    // ^
    token_address,                  // @

    token_coma,                     // ,
    token_dot,                      // .
    token_openround,                // (
    token_closeround,               // )
    token_openblock,                // [
    token_closeblock,               // ]
    token_openfigure,               // {
    token_closefigure,              // }

    token_absolute,                 // keyword: absolute
    token_asm,                      // keyword: asm
    token_stdcall,                  // keyword: stdcall
    token_fastcall,                 // keyword: fastcall
    token_cdecl,                    // keyword: cdecl
    token_unit,                     // keyword: unit
    token_uses,                     // keyword: uses
    token_using,                    // keyword: using

    token_program,                  // keyword: program
    token_pure,                     // keyword: pure
    token_library,                  // keyword: library

    token_export,                   // keyword: export
    token_external,                 // keyword: extern
    token_name,                     // keyword: name
    token_exit,                     // keyword: exit
    token_interface,                // keyword: interface
    token_implementation,           // keyword: implementation
    token_implement,                // keyword: implementation
    token_initialization,           // keyword: initialization
    token_finalization,             // keyword: finalization
    token_begin,                    // keyword: begin
    token_end,                      // keyword: end
    token_var,                      // keyword: var
    token_out,                      // keyword: out
    token_const,                    // keyword: const
    token_constref,                 // keyword: constref
    token_procedure,                // keyword: procedure
    token_function,                 // keyword: function
    token_overload,                 // keyword: overload
    token_override,                 // keyword: override
    token_openarray,                // keyword: openarray
    token_type,                     // keyword: type
    token_token,                    // keyword: #token
    token_class,                    // keyword: class
    token_record,                   // keyword: record
    token_packed,                   // keyword: packed
    token_package,                  // keyword: package
    token_bindf,                    // keyword: bind
    token_set,                      // keyword: set
    token_array,                    // keyword: array
    token_if,                       // keyword: if
    token_iif,                      // keyword: iif
    token_icase,                    // keyword: icase
    token_in,                       // keyword: in
    //token_index,                    // keyword: index
    token_inline,                   // keyword: inline
    token_is,                       // keyword: is
    token_then,                     // keyword: if
    token_else,                     // keyword: else
    token_forward,                  // keyword: forward
    token_noreturn,                 // keyword: noreturn
    token_namespace,                // keyword: namespace
    token_helper,                   // keyword: helper

    token_continue,                 // keyword: continue
    token_break,                    // keyword: break

    token_async,                    // keyword: async
    token_await,                    // keyword: await

    token_not,                      // keyword: not
    token_and,                      // keyword: and
    token_or,                       // keyword: or
    token_xor,                      // keyword: xor

    token_div,                      // keyword: div
    token_mod,                      // keyword: mod
    token_shl,                      // keyword: shl
    token_shr,                      // keyword: shr
    token_rol,                      // keyword: rol
    token_ror,                      // keyword: ror
    token_ref,                      // keyword: ref

    token_as,                       // keyword: as
    token_for,                      // keyword: for
    token_to,                       // keyword: to
    token_downto,                   // keyword: downto
    token_do,                       // keyword: do
    token_deprecated,               // keyword: depricated
    token_while,                    // keyword: while
    token_weak,                     // keyword: weak
    token_repeat,                   // keyword: repeat
    token_reintroduce,              // keyword: reintroduce
    token_until,                    // keyword: until
    token_union,                    // keyword: union
    token_unsafe,                   // keyword: unsafe
    token_with,                     // keyword: until
    token_case,                     // keyword: case
    token_of,                       // keyword: of
    token_object,                   // keyword: object
    token_operator,                 // keyword: operator
    token_try,                      // keyword: try
    token_finally,                  // keyword: finally
    token_except,                   // keyword: except
    token_raise,                    // keyword: raise
    token_strict,                   // keyword: strict
    token_step,                     // keyword: step
    token_property,                 // keyword: property
    token_private,                  // keyword: private
    token_protected,                // keyword: protected
    token_public,                   // keyword: public
    token_published,                // keyword: published
    token_read,                     // keyword: read
    token_write,                    // keyword: write
    token_inherited,                // keyword: inherited
    token_virtual,                  // keyword: virtual
    token_dynamic,                  // keyword: dynamic
    token_static,                   // keyword: static
    token_constructor,              // keyword: constructor
    token_destructor,               // keyword: destructor
    token_default,                  // keyword: default

    token_cond_macro,               // #macro
    token_cond_emit,                // #emit
    token_cond_target,              // #target

    token_cond_define,              // #define
    token_cond_undefine,            // #undefine
    token_cond_ifdef,               // #ifdef
    token_cond_ifndef,              // #ifndef
    token_cond_if,                  // #if
    token_cond_else,                // #else
    token_cond_end,                 // #end
    token_cond_include,             // #include
    token_cond_error,               // #error
    token_cond_warning,             // #warning
    token_cond_hint,                // #hint
    token_cond_skip,                // #skip
    token_cond_doc,                 // #doc
    token_cond_breakpoint,          // #bpt
    token_cond_opt_set,             // #set
    token_cond_opt_push,            // #push
    token_cond_opt_pop,             // #pop

    token_delphi_cond_define,       // #define
    token_delphi_cond_undefine,     // #undefine
    token_delphi_cond_ifdef,        // #ifdef
    token_delphi_cond_ifndef,       // #ifndef
    token_delphi_cond_if            // #if
  );

  TNPParser = class(TStringParser)
  public
    function NextToken: TTokenID; inline;
    function TokenLexem(TokenID: TTokenID): string;
    constructor Create(const Source: string); override;
    procedure RegisterToken(const Token: string; TokenID: TTokenID; const TokenCaption: string; TokenType: TTokenType = ttToken); overload;
    procedure RegisterToken(const Token: string; TokenID: TTokenID; CanBeID: Boolean = False); overload;
    procedure ReadCurrIdentifier(var Identifier: TIdentifier); inline;
    procedure ReadNextIdentifier(var Identifier: TIdentifier); inline;
    procedure MatchToken(ActualToken, ExpectedToken: TTokenID); inline;
    procedure MatchNextToken(ExpectedToken: TTokenID); inline;
  end;

  function TokenCanBeID(TokenID: TTokenID): Boolean; inline;

var
  FTokensAttr: array [TTokenID] of Boolean;


implementation

{ TiDealParser }


function TokenCanBeID(TokenID: TTokenID): Boolean;
begin
  Result := FTokensAttr[TokenID];
end;

procedure TNPParser.ReadCurrIdentifier(var Identifier: TIdentifier);
begin
  Identifier.Name := OriginalToken;
  Identifier.TextPosition := Position;
end;

procedure TNPParser.ReadNextIdentifier(var Identifier: TIdentifier);
begin
  if NextToken = token_Identifier then begin
    Identifier.Name := OriginalToken;
    Identifier.TextPosition := Position;
  end else
    AbortWork(sIdExpectedButFoundFmt, [TokenLexem(TTokenID(CurrentTokenID))], PrevPosition);
end;

procedure TNPParser.MatchToken(ActualToken, ExpectedToken: TTokenID);
begin
  if ActualToken <> ExpectedToken then
    AbortWork(sExpected, [UpperCase(TokenLexem(ExpectedToken))], PrevPosition);
end;

constructor TNPParser.Create(const Source: string);
begin
  inherited Create(Source);
  IdentifireID := integer(token_identifier);
  EofID := integer(token_eof);
  TokenCaptions.AddObject('end of file', TObject(token_eof));
  TokenCaptions.AddObject('identifier', TObject(token_identifier));
  SeparatorChars := '#$ '''#9#10#13'%^&*@()+-{}[]\/,.;:<>=~!?';
  RegisterToken('#', token_NumberSign, '', ttCharCode);
  RegisterToken('#define', token_cond_define);
  RegisterToken('#else', token_cond_else);
  RegisterToken('#end', token_cond_end);
  RegisterToken('#if', token_cond_if);
  RegisterToken('#ifdef', token_cond_ifdef);
  RegisterToken('#ifndef', token_cond_ifndef);
  RegisterToken('#undefine', token_cond_undefine);
  RegisterToken('#include', token_cond_include);
  RegisterToken('#error', token_cond_error);
  RegisterToken('#warning', token_cond_warning);
  RegisterToken('#hint', token_cond_hint);
  RegisterToken('#token', token_token);
  RegisterToken('#target', token_cond_target);
  RegisterToken('#skip', token_cond_skip);
  RegisterToken('#doc', token_cond_doc);
  RegisterToken('#bpt', token_cond_breakpoint);

  RegisterToken('#macro', token_cond_macro);
  RegisterToken('#emit', token_cond_emit);

  RegisterToken('#set', token_cond_opt_set);
  RegisterToken('#push', token_cond_opt_push);
  RegisterToken('#pop', token_cond_opt_pop);

  RegisterToken('$', token_Unknown, '', ttHexPrefix);
  RegisterToken('%', token_Unknown, '', ttBinPrefix);
  RegisterToken(' ', token_Unknown, '', ttOmited);
  RegisterToken(#9, token_Unknown, '', ttOmited);
  RegisterToken(#10, token_Unknown, '', ttNewLine);
  RegisterToken(#13#10, token_Unknown, '', ttNewLine);
  RegisterToken(#13, token_Unknown, '', ttOmited);
  RegisterToken('''', token_unknown, '', ttQuote);
  RegisterToken('"', token_unknown, '', ttQuoteMulti);
  RegisterToken('//', token_unknown, '', ttOneLineRem);
  RegisterToken(';', token_semicolon, 'semicolon');
  RegisterToken(',', token_coma, 'coma');
  RegisterToken(':', token_colon, 'colon');
  RegisterToken('=', token_equal, 'equal');
  RegisterToken('>', token_above);
  RegisterToken('>=', token_aboveorequal);
  RegisterToken('<', token_less);
  RegisterToken('<=', token_lessorequal);
  RegisterToken('<>', token_notequal);
  RegisterToken('.', token_dot, 'dot', ttToken);
  RegisterToken('..', token_period, 'period');
  RegisterToken('(', token_openround, 'open round');
  RegisterToken(')', token_closeround, 'close round');
  RegisterToken('[', token_openblock);
  RegisterToken(']', token_closeblock);
  RegisterToken('{', token_openfigure);
  RegisterToken('}', token_closefigure);
  RegisterToken('+', token_plus, 'plus');
  RegisterToken('++', token_plusplus, 'plusplus');
  RegisterToken('-', token_minus, 'minus');
  RegisterToken('--', token_minusminus, 'minusminus');
  RegisterToken('~', token_lambda, 'lambda');
  RegisterToken('!', token_exclamation, 'exclamation');
  RegisterToken('?', token_question, 'question');
  RegisterToken('*', token_asterisk, 'asterisk');
  RegisterToken('/', token_slash);
  RegisterToken('^', token_caret);
  RegisterToken('@', token_address);
  RegisterToken(':=', token_assign);
  RegisterToken('absolute', token_absolute);
  RegisterToken('as', token_as);
  RegisterToken('asm', token_asm);
  RegisterToken('and', token_and);
  RegisterToken('array', token_array);
  RegisterToken('async', token_async);
  RegisterToken('await', token_await);
  RegisterToken('begin', token_begin, True);
  RegisterToken('break', token_break);
  RegisterToken('case', token_case);
  RegisterToken('cdecl', token_cdecl, True);
  RegisterToken('const', token_const);
  RegisterToken('constref', token_constref);
  RegisterToken('constructor', token_constructor);
  RegisterToken('continue', token_continue);
  RegisterToken('class', token_class);
  RegisterToken('do', token_do);
  RegisterToken('downto', token_downto);
  RegisterToken('div', token_div);
  RegisterToken('destructor', token_destructor);
  RegisterToken('deprecated', token_deprecated);
  RegisterToken('default', token_default, True);
  RegisterToken('dynamic', token_dynamic);
  RegisterToken('end', token_end);
  RegisterToken('else', token_else);
  RegisterToken('exit', token_exit);
  RegisterToken('except', token_except);
  RegisterToken('export', token_export);
  RegisterToken('external', token_external);
  RegisterToken('function', token_Function);
  RegisterToken('for', token_for);
  RegisterToken('forward', token_forward);
  RegisterToken('finally', token_finally);
  RegisterToken('finalization', token_finalization);
  RegisterToken('fastcall', token_fastcall);
  RegisterToken('if', token_if);
  RegisterToken('iif', token_iif);
  RegisterToken('is', token_is);
  RegisterToken('in', token_in);
  //RegisterToken('index', token_index);
  RegisterToken('interface', token_Interface);
  RegisterToken('inherited', token_inherited);
  RegisterToken('inline', token_inline);
  RegisterToken('initialization', token_initialization);
  RegisterToken('implementation', token_Implementation);
  RegisterToken('implement', token_implement);
  RegisterToken('library', token_library);
  RegisterToken('mod', token_mod);
  RegisterToken('not', token_not);
  RegisterToken('noreturn', token_noreturn);
  RegisterToken('name', token_name, true);
  RegisterToken('namespace', token_namespace, true);
  RegisterToken('object', token_object, True);
  RegisterToken('of', token_of);
  RegisterToken('or', token_or);
  RegisterToken('out', token_Out);
  RegisterToken('override', token_Override);
  RegisterToken('overload', token_Overload);
  RegisterToken('operator', token_operator);
  RegisterToken('openarray', token_openarray);
  RegisterToken('package', token_package);
  RegisterToken('bind', token_bindf);
  RegisterToken('procedure', token_procedure);
  RegisterToken('program', token_program);
  RegisterToken('property', token_property);
  RegisterToken('protected', token_protected);
  RegisterToken('program', token_program);
  RegisterToken('private', token_private);
  RegisterToken('pure', token_pure);
  RegisterToken('public', token_public);
  RegisterToken('published', token_published);
  RegisterToken('packed', token_packed);
  RegisterToken('raise', token_raise);
  RegisterToken('read', token_read, True);
  RegisterToken('record', token_record);
  RegisterToken('ref', token_ref, True);
  RegisterToken('repeat', token_repeat);
  RegisterToken('reintroduce', token_reintroduce);
  RegisterToken('rol', token_rol);
  RegisterToken('ror', token_ror);
  RegisterToken('set', token_set);
  RegisterToken('shl', token_shl);
  RegisterToken('shr', token_shr);
  RegisterToken('static', token_static);
  RegisterToken('strict', token_strict);
  RegisterToken('step', token_step);
  RegisterToken('stdcall', token_stdcall);
  RegisterToken('then', token_then);
  RegisterToken('to', token_to);
  RegisterToken('try', token_try);
  RegisterToken('type', token_type);
  RegisterToken('helper', token_helper);
  RegisterToken('until', token_until);
  RegisterToken('unit', token_unit);
  RegisterToken('union', token_union);
  RegisterToken('unsafe', token_unsafe);
  RegisterToken('uses', token_uses);
  RegisterToken('using', token_using);
  RegisterToken('var', token_Var);
  RegisterToken('virtual', token_virtual);
  RegisterToken('weak', token_weak);
  RegisterToken('with', token_with);
  RegisterToken('while', token_while);
  RegisterToken('write', token_write, True);
  RegisterToken('xor', token_xor);
  RegisterRemToken('{', '}', ord(token_closefigure), Ord(token_closefigure));
  RegisterRemToken('(*', '*)', ord(token_closefigure), Ord(token_closefigure)); // !!!

  RegisterToken('{$DEFINE', token_delphi_cond_define);
  RegisterToken('{$UNDEFINE', token_delphi_cond_undefine);
  RegisterToken('{$IFDEF', token_delphi_cond_ifdef);
  RegisterToken('{$IFNDEF', token_delphi_cond_ifndef);
  RegisterToken('{$IF', token_delphi_cond_if);
  RegisterToken('{$ELSE}', token_cond_else);
  RegisterToken('{$ENDIF}', token_cond_end);
  RegisterToken('{$IFEND}', token_cond_end);
end;

procedure TNPParser.MatchNextToken(ExpectedToken: TTokenID);
begin
  if TTokenID(NextTokenID) <> ExpectedToken then
    AbortWork(sExpected, [UpperCase(TokenLexem(ExpectedToken))], PrevPosition);
end;

function TNPParser.NextToken: TTokenID;
begin
  Result := TTokenID(NextTokenID);
end;

procedure TNPParser.RegisterToken(const Token: string; TokenID: TTokenID; const TokenCaption: string; TokenType: TTokenType);
begin
  inherited RegisterToken(Token, Integer(TokenID), TokenType, TokenCaption);
  FTokensAttr[TokenID] := False;
end;

procedure TNPParser.RegisterToken(const Token: string; TokenID: TTokenID; CanBeID: Boolean);
begin
  inherited RegisterToken(Token, Integer(TokenID), ttToken, Token);
  FTokensAttr[TokenID] := CanBeID;
end;

function TNPParser.TokenLexem(TokenID: TTokenID): string;
begin
  Result := inherited TokenLexem(Integer(TokenID));
end;

end.

