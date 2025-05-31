-- +----------------------------------------+
-- | Template: LbtDoc                       |
-- |                                        |
-- | Purpose: Provide commands useful for   |
-- |          documenting LBT.              |
-- +----------------------------------------+

local F = string.format
local T = lbt.util.string_template_expand
local f = {}
local a = {}
local op = {}
local m = {}

local impl = {}

local init = function()
  local setup = [[
\tcbset{
  lbtSource/.style={
    colback=blue!5,             % light blue background
    colframe=blue!80!black,     % darker blue frame
    boxrule=0.8pt,              % frame thickness
    arc=3pt,                    % rounded corners
    frame style={dotted},       % dotted border
    enhanced,                   % enable TikZ enhancements (needed for frame style)
    left=6pt, right=6pt, top=6pt, bottom=6pt, % padding
  }
}
\tcbset{
  lbtResult/.style={
    colback=blue!5,             % light blue background
    colframe=blue!80!black,     % darker blue frame
    boxrule=0.8pt,              % frame thickness
    arc=3pt,                    % rounded corners
    frame style={dotted},       % dotted border
    enhanced,                   % enable TikZ enhancements (needed for frame style)
    left=6pt, right=6pt, top=6pt, bottom=6pt, % padding
  }
}
  ]]
  lbt.util.print_tex_lines(setup)
end

a.LBTEXAMPLE = 1
op.LBTEXAMPLE = { horizontal = true, vertical = false, shrinkmargin = 'nil',
                  float = false, position = 'bp', par = true, output = 2,
                  scale = 1.0 }
-- output: 0 = raw only, 1 = latex code, 2 = final result. So n = number of processing stages.
f.LBTEXAMPLE = function(_, args, o, kw)
  -- code_input is LBT code, code_output is Latex code
  --   (if o.output is 0 then code_output is nil; if 1 then code_output is verbatim Latex,
  --    if 2 then ordinary Latex)
  -- orientation is 'H' or 'V'
  -- result_latex is the tcolorbox inside an adjustmargin and possibly a figure
  --
  -- (1) Do the work to format input and (optionally) output into a tcolorbox.
  local code_input = impl.perform_substitution(kw.substitute, args[1])
  local code_output
  local result_latex
  local orientation = impl.orientation(o)
  if o.output == 0 then
    code_output = nil
  elseif o.output == 1 then
    code_output = impl.compile_lbt_to_latex_or_warning(code_input)
    code_output = impl.verbatim_uncommented_latex_code(code_output)
  elseif o.output == 2 then
    code_output = impl.compile_lbt_to_latex_or_warning(code_input)
  end
  local box = impl.lbt_example_tcolorbox { input = code_input, output = code_output,
                                           orientation = orientation, scale = o.scale }
  --
  -- (2) Apply 'shrinkmargin' and 'float' options, if appropriate.
  result_latex = box
  if o.shrinkmargin then
    result_latex = T {
      [[\begin{adjustwidth}{-!SIZE!}{-!SIZE!}]],
      result_latex,
      [[\end{adjustwidth}]],
      values = {
        SIZE = o.shrinkmargin
      }
    }
  end
  if o.float then
    result_latex = T { [[
        \begin{example}[!POSITION!] !ADJUSTCAPTIONMARGIN!
          !CONTENT!
          !CAPTION!
          \label{!LABEL!}
        \end{example}
      ]],
      values = {
        ADJUSTCAPTIONMARGIN = impl.adjustcaptionmargin(o),
        POSITION = o.position,
        CONTENT = result_latex,
        CAPTION = kw.caption and F([[\caption{%s}]], kw.caption) or '(caption)',
        LABEL = kw.label or 'ex:abc',
      }
    }
  end
  return result_latex
end

impl.orientation = function(o)
  if o.vertical then
    return 'vertical'
  elseif o.horizontal then
    return 'horizontal'
  else
    lbt.util.template_error_quit('LBTEXAMPLE: need o.horizontal or o.vertical')
  end
end

impl.compile_lbt_to_latex_or_warning = function(code)
  local ok, result = pcall(
    function() return lbt.util.lbt_commands_text_into_latex(code) end
  )
  if ok then
    return result
  else
    lbt.debuglog('Error in LBTEXAMPLE code --')
    lbt.debuglograw(result)
    return [[\lbtWarning{Error in code. See debuglog.} \par ]]
  end
end

impl.lbt_example_tcolorbox = function(args)
  local orientation = ''
  if args.orientation == 'horizontal' then orientation = 'sidebyside' end
  if args.output == nil then
    return F(impl.tcolorbox_template1, '', args.input)
  else
    return F(impl.tcolorbox_template2, orientation, args.input, args.output)
  end
end

impl.tcolorbox_template1 = [[
  \begin{tcolorbox}[before skip=2pt, after skip=2pt, %s]
    \begin{small}
      \begin{Verbatim}[formatcom=\color{NavyBlue}, breaklines=true]
        %s
      \end{Verbatim}
    \end{small}
  \end{tcolorbox}
]]

impl.tcolorbox_template2 = [[
  \begin{tcolorbox}[before skip=2pt, after skip=2pt, %s]
    \begin{small}
      \begin{Verbatim}[formatcom=\color{NavyBlue}, breaklines=true]
        %s
      \end{Verbatim}
    \end{small}
    \tcblower
    \begin{small}
      %s
    \end{small}
  \end{tcolorbox}
]]

impl.perform_substitution = function(sub_spec, text)
  if sub_spec == nil then return text end
  local bits = lbt.util.split(sub_spec, '/')
  local a, b = bits[2], bits[3]
  local x = text:gsub(a, b)
  return x
end

impl.verbatim_uncommented_latex_code = function(text)
  local lines = lbt.util.newline_split(text)
  lines = lines:filter(function(x) return not x:startswith('%') end)
  return F([[
\begin{Verbatim}
%s
\end{Verbatim}
  ]], lines:concat('\n'))
end

impl.adjustcaptionmargin = function(o)
  if o.shrinkmargin then
    return F([[\captionsetup{margin={-%s,-%s}}]], o.shrinkmargin, o.shrinkmargin)
  else
    return ''
  end
end

-- XXX: I think CODESAMPLE is no longer needed.

a.CODESAMPLE = 1
op.CODESAMPLE = { float = false, position = 'htbp' }
f.CODESAMPLE = function(n, args, o, kw)
  local verbatim_latex = T { [[
      \begin{Verbatim}[breaklines,fontsize=\small,xleftmargin=5mm,frame=single]
        !TEXT!
      \end{Verbatim}
    ]], values = {
      TEXT = args[1]
    }
  }
  if o.float then
    return T { [[
        \begin{figure}[!POSITION!]
          !CONTENT!
          !CAPTION!
          \label{!LABEL!}
        \end{figure}
      ]],
      values = {
        POSITION = o.position,
        CONTENT = verbatim_latex,
        CAPTION = kw.caption and F([[\caption{%s}]], kw.caption) or '',
        LABEL = kw.label or error('no label'),
      }
    }
  else
    return verbatim_latex
  end
end

a.NOTE = 1
f.NOTE = function (n, args, o)
  return F([[
    \begin{tcolorbox}[colback=red!5!white, colframe=red!75!black, title=Note]
      %s
    \end{tcolorbox}
  ]], args[1])
end


return {
  name      = 'LbtDoc',
  sources   = {},
  desc      = 'Commands useful for documenting LBT.',
  init      = init,
  expand    = nil,
  functions = f,
  opargs    = op,
  posargs   = a,
  macros    = m,
}

