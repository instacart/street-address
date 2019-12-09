module StreetAddress
  class Canada < US

    STATE_CODES = {
        "alberta"			=> "AB",
        "british columbia" 		=> "BC",
        "manitoba"			=> "MB",
        "new brunswick"			=> "NB",
        "newfoundland and labrador"	=> "NL",
        "northwest territories"		=> "NT",
        "nova scotia"			=> "NS",
        "nunavut"			=> "NU",
        "ontario"			=> "ON",
        "prince edward island"		=> "PE",
        "quebec"			=> "PQ",
        "saskatchewan"			=> "SK",
        "yukon"				=> "YT",
        "alta"				=> "AB",
        "b.c."				=> "BC",
        "man"				=> "MB",
        "n.b."				=> "NB",
        "n.f."				=> "NL",
        "n.w.t."			=> "NT",
        "nwt"				=> "NT",
        "n.s."				=> "NS",
        "ont"				=> "ON",
        "p.e.i"				=> "PE",
        "pei"				=> "PE",
        "pq"				=> "QC",
        "que"				=> "QC",
        "sask"				=> "SK",
        "yuk"				=> "YT",
        "y.t."				=> "YT",
    }

    STATE_NAMES = STATE_CODES.invert

    STATE_FIPS = {
        "01" => "AL",
        "02" => "AB",
        "04" => "AZ",
        "05" => "AR",
        "06" => "CA",
        "08" => "CO",
        "09" => "CT",
        "10" => "DE",
        "11" => "DC",
        "12" => "FL",
        "13" => "GA",
        "15" => "HI",
        "16" => "ID",
        "17" => "IL",
        "18" => "IN",
        "19" => "IA",
        "20" => "KS",
        "21" => "KY",
        "22" => "LA",
        "23" => "ME",
        "24" => "MD",
        "25" => "MA",
        "26" => "MI",
        "27" => "MN",
        "28" => "MS",
        "29" => "MO",
        "30" => "MT",
        "31" => "NE",
        "32" => "NV",
        "33" => "NH",
        "34" => "NJ",
        "35" => "NM",
        "36" => "NY",
        "37" => "NC",
        "38" => "ND",
        "39" => "OH",
        "40" => "OK",
        "41" => "OR",
        "42" => "PA",
        "44" => "RI",
        "45" => "SC",
        "46" => "SD",
        "47" => "TN",
        "48" => "TX",
        "49" => "UT",
        "50" => "VT",
        "51" => "VA",
        "53" => "WA",
        "54" => "WV",
        "55" => "WI",
        "56" => "WY",
        "72" => "PR",
        "78" => "VI"
    }

    FIPS_STATES = STATE_FIPS.invert


    class << self
      attr_accessor(
          :street_type_regexp,
          :street_type_matches,
          :number_regexp,
          :fraction_regexp,
          :state_regexp,
          :city_and_state_regexp,
          :direct_regexp,
          :zip_regexp,
          :corner_regexp,
          :unit_regexp,
          :street_regexp,
          :place_regexp,
          :address_regexp,
          :informal_address_regexp,
          :dircode_regexp,
          :unit_prefix_numbered_regexp,
          :unit_prefix_unnumbered_regexp,
          :unit_regexp,
          :sep_regexp,
          :sep_avoid_unit_regexp,
          :intersection_regexp
      )
    end

    self.street_type_matches = {}
    STREET_TYPES.each_pair { |type,abbrv|
      self.street_type_matches[abbrv] = /\b (?: #{abbrv}|#{Regexp.quote(type)} ) \b/ix
    }

    self.street_type_regexp = Regexp.new(STREET_TYPES_LIST.keys.join("|"), Regexp::IGNORECASE)
    self.fraction_regexp = /\d+\/\d+/
    self.state_regexp = Regexp.new(
        '\b' + STATE_CODES.flatten.map{ |code| Regexp.quote(code) }.join("|") + '\b',
        Regexp::IGNORECASE
    )
    self.direct_regexp = Regexp.new(
        (DIRECTIONAL.keys +
            DIRECTIONAL.values.sort { |a,b|
              b.length <=> a.length
            }.map { |c|
              f = c.gsub(/(\w)/, '\1.')
              [Regexp::quote(f), Regexp::quote(c)]
            }
        ).join("|"),
        Regexp::IGNORECASE
    )
    self.dircode_regexp = Regexp.new(DIRECTION_CODES.keys.join("|"), Regexp::IGNORECASE)
    self.zip_regexp     = /(?:(?<postal_code>[a-zA-Z]\d{1}[a-zA-Z](\-| |)\d{1}[a-zA-Z]\d{1})(?:-?(?<postal_code_ext>\d{4}))?)/
    self.corner_regexp  = /(?:\band\b|\bat\b|&|\@)/i

    # we don't include letters in the number regex because we want to
    # treat "42S" as "42 S" (42 South). For example,
    # Utah and Wisconsin have a more elaborate system of block numbering
    # http://en.wikipedia.org/wiki/House_number#Block_numbers
    self.number_regexp = /(?<number>\d+-?\d*)(?=\D)/ix

    # note that expressions like [^,]+ may scan more than you expect
    self.street_regexp = /
      (?:
        # special case for addresses like 100 South Street
        (?:(?<street> #{direct_regexp})\W+
           (?<street_type> #{street_type_regexp})\b
        )
        |
        (?:(?<prefix> #{direct_regexp})\W+)?
        (?:
          (?<street> [^,]*\d)\b
          (?:[^\w,]* (?<suffix> #{direct_regexp})\b)
          |
          (?<street> [^,]+)
          (?:[^\w,]+(?<street_type> #{street_type_regexp})\b)
          (?:[^\w,]+(?<suffix> #{direct_regexp})\b)?
          |
          (?<street> [^,]+?)
          (?:[^\w,]+(?<street_type> #{street_type_regexp})\b)?
          (?:[^\w,]+(?<suffix> #{direct_regexp})\b)?
        )
      )
    /ix;

    # http://pe.usps.com/text/pub28/pub28c2_003.htm
    # TODO add support for those that don't require a number
    # TODO map to standard names/abbreviations
    self.unit_prefix_numbered_regexp = /
      (?<unit_prefix>
        su?i?te
        |p\W*[om]\W*b(?:ox)?
        |(?:ap|dep)(?:ar)?t(?:me?nt)?
        |ro*m
        |flo*r?
        |uni?t
        |bu?i?ldi?n?g
        |ha?nga?r
        |lo?t
        |pier
        |slip
        |spa?ce?
        |stop
        |tra?i?le?r
        |box)(?![a-z])
    /ix;

    self.unit_prefix_unnumbered_regexp = /
      (?<unit_prefix>
        ba?se?me?n?t
        |fro?nt
        |lo?bby
        |lowe?r
        |off?i?ce?
        |pe?n?t?ho?u?s?e?
        |rear
        |side
        |uppe?r
        )\b
    /ix;

    self.unit_regexp = /
      (?:
          (?: (?:#{unit_prefix_numbered_regexp} \W*)
              | (?<unit_prefix> \#)\W*
          )
          (?<unit> [\w-]+)
      )
      |
      #{unit_prefix_unnumbered_regexp}
    /ix;

    self.city_and_state_regexp = /
      (?:
          (?<city> [^\d,]+?)\W+
          (?<state> #{state_regexp})
      )
    /ix;

    self.place_regexp = /
      (?:#{city_and_state_regexp}\W*)? (?:#{zip_regexp})?
    /ix;

    self.address_regexp = /
      \A
      [^\w\x23]*    # skip non-word chars except # (eg unit)
      (
        # checks if unit is before the number
        (?:#{unit_regexp}\W+)
        #{number_regexp} \W*
        (?:#{fraction_regexp}\W*)?
        #{street_regexp}\W+
        #{place_regexp}
      )
      |
      (
        #{number_regexp} \W*
        (?:#{fraction_regexp}\W*)?
        #{street_regexp}\W+
        (?:#{unit_regexp}\W+)?
        #{place_regexp}
      )

      \W*         # require on non-word chars at end
      \z           # right up to end of string
    /ix;

    self.sep_regexp = /(?:\W+|\Z)/;
    self.sep_avoid_unit_regexp = /(?:[^\#\w]+|\Z)/;

    self.informal_address_regexp = /
      \A
      \s*         # skip leading whitespace
      (?:#{unit_regexp} #{sep_regexp})?
      (?:#{number_regexp})? \W*
      (?:#{fraction_regexp} \W*)?
      #{street_regexp} #{sep_avoid_unit_regexp}
      (?:#{unit_regexp} #{sep_regexp})?
      (?:#{place_regexp})?
      # don't require match to reach end of string
    /ix;

    self.intersection_regexp = /\A\W*
      #{street_regexp}\W*?

      \s+#{corner_regexp}\s+

#          (?{ exists $_{$_} and $_{$_.1} = delete $_{$_} for (qw{prefix street type suffix})})
      #{street_regexp}\W+
#          (?{ exists $_{$_} and $_{$_.2} = delete $_{$_} for (qw{prefix street type suffix})})

      #{place_regexp}
      \W*\z
    /ix;

  end
end
