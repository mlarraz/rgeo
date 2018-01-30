# -----------------------------------------------------------------------------
#
# OGC CS objects for RGeo
#
# -----------------------------------------------------------------------------

module RGeo
  module CoordSys
    module CS
      # An axis orientation constant for AxisInfo.
      # Unknown or unspecified axis orientation. This can be used for
      # local or fitted coordinate systems.
      AO_OTHER = 0

      # An axis orientation constant for AxisInfo.
      # Increasing ordinates values go North. This is usually used for
      # Grid Y coordinates and Latitude.
      AO_NORTH = 1

      # An axis orientation constant for AxisInfo.
      # Increasing ordinates values go South. This is rarely used.
      AO_SOUTH = 2

      # An axis orientation constant for AxisInfo.
      # Increasing ordinates values go East. This is rarely used.
      AO_EAST = 3

      # An axis orientation constant for AxisInfo.
      # Increasing ordinates values go West. This is usually used for
      # Grid X coordinates and Longitude.
      AO_WEST = 4

      # An axis orientation constant for AxisInfo.
      # Increasing ordinates values go up. This is used for vertical
      # coordinate systems.
      AO_UP = 5

      # An axis orientation constant for AxisInfo.
      # Increasing ordinates values go down. This is used for vertical
      # coordinate systems.
      AO_DOWN = 6

      # A datum type constant for HorizontalDatum.
      # Lowest possible value for horizontal datum types.
      HD_MIN = 1000

      # A datum type constant for HorizontalDatum.
      # Unspecified horizontal datum type. Horizontal datums with this
      # type should never supply a conversion to WGS84 using Bursa Wolf
      # parameters.
      HD_OTHER = 1000

      # A datum type constant for HorizontalDatum.
      # These datums, such as ED50, NAD27 and NAD83, have been designed
      # to support horizontal positions on the ellipsoid as opposed to
      # positions in 3-D space. These datums were designed mainly to
      # support a horizontal component of a position in a domain of
      # limited extent, such as a country, a region or a continent.
      HD_CLASSIC = 1001

      # A datum type constant for HorizontalDatum.
      # A geocentric datum is a "satellite age" modern geodetic datum
      # mainly of global extent, such as WGS84 (used in GPS), PZ90 (used
      # in GLONASS) and ITRF. These datums were designed to support both
      # a horizontal component of position and a vertical component of
      # position (through ellipsoidal heights). The regional realizations
      # of ITRF, such as ETRF, are also included in this category.
      HD_GEOCENTRIC = 1002

      # A datum type constant for HorizontalDatum.
      # Highest possible value for horizontal datum types.
      HD_MAX = 1999

      # A datum type constant for VerticalDatum.
      # Lowest possible value for vertical datum types.
      VD_MIN = 2000

      # A datum type constant for VerticalDatum.
      # Unspecified vertical datum type.
      VD_OTHER = 2000

      # A datum type constant for VerticalDatum.
      # A vertical datum for orthometric heights that are measured along
      # the plumb line.
      VD_ORTHOMETRIC = 2001

      # A datum type constant for VerticalDatum.
      # A vertical datum for ellipsoidal heights that are measured along
      # the normal to the ellipsoid used in the definition of horizontal
      # datum.
      VD_ELLIPSOIDAL = 2002

      # A datum type constant for VerticalDatum.
      # The vertical datum of altitudes or heights in the atmosphere.
      # These are approximations of orthometric heights obtained with the
      # help of a barometer or a barometric altimeter. These values are
      # usually expressed in one of the following units: meters, feet,
      # millibars (used to measure pressure levels), or theta value (units
      # used to measure geopotential height).
      VD_ALTITUDE_BAROMETRIC = 2003

      # A datum type constant for VerticalDatum.
      # A normal height system.
      VD_NORMAL = 2004

      # A datum type constant for VerticalDatum.
      # A vertical datum of geoid model derived heights, also called
      # GPS-derived heights. These heights are approximations of
      # orthometric heights (H), constructed from the ellipsoidal heights
      # (h) by the use of the given geoid undulation model (N) through
      # the equation: H=h-N.
      VD_GEOID_MODE_DERIVED = 2005

      # A datum type constant for VerticalDatum.
      # This attribute is used to support the set of datums generated for
      # hydrographic engineering projects where depth measurements below
      # sea level are needed. It is often called a hydrographic or a
      # marine datum. Depths are measured in the direction perpendicular
      # (approximately) to the actual equipotential surfaces of the
      # earth's gravity field, using such procedures as echo-sounding.
      VD_DEPTH = 2006

      # A datum type constant for VerticalDatum.
      # Highest possible value for vertical datum types.
      VD_MAX = 2999

      # A datum type constant for LocalDatum.
      # Lowest possible value for local datum types.
      LD_MIN = 10_000

      # A datum type constant for LocalDatum.
      # Highest possible value for local datum types.
      LD_MAX = 32_767

      # This is a base class for all OGC coordinate system objects.
      # This includes both interfaces and data types from the OGC
      # Coordinate Transformation spec.
      #
      # This is a non-instantiable abstract class.

      class Base
        # Standard object inspection output

        def inspect
          "#<#{self.class}:0x#{object_id.to_s(16)} #{to_wkt}>"
        end

        # Tests for equality. Two objects are defined as equal if they
        # have the same type (class) and the same WKT representation.

        def eql?(rhs)
          rhs.class == self.class && rhs.to_wkt == to_wkt
        end
        alias == eql?

        # Standard hash code

        def hash
          @hash ||= to_wkt.hash
        end

        # Returns the default WKT representation.

        def to_s
          to_wkt
        end

        # Computes the WKT representation. Options include:
        #
        # [<tt>:standard_brackets</tt>]
        #   If set to true, outputs parentheses rather than square
        #   brackets. Default is false.

        def to_wkt(opts = {})
          if opts[:standard_brackets]
            @standard_wkt ||= _to_wkt("(", ")")
          else
            @square_wkt ||= _to_wkt("[", "]")
          end
        end

        def _to_wkt(open, close) # :nodoc:
          content = _wkt_content(open, close).map { |obj| ",#{obj}" }.join
          if defined?(@authority) && @authority
            authority = ",AUTHORITY#{open}#{@authority.inspect},#{@authority_code.inspect}#{close}"
          else
            authority = ""
          end
          if defined?(@extensions) && @extensions
            extensions = @extensions.map { |k, v| ",EXTENSION#{open}#{k.inspect},#{v.inspect}#{close}" }.join
          else
            extensions = ""
          end
          "#{_wkt_typename}#{open}#{@name.inspect}#{content}#{extensions}#{authority}#{close}"
        end

        # Marshal support

        def marshal_dump # :nodoc:
          to_wkt
        end

        def marshal_load(data) # :nodoc:
          data = data["wkt"] if data.is_a?(::Hash)
          temp = CS.create_from_wkt(data)
          if temp.class == self.class
            temp.instance_variables.each do |iv|
              instance_variable_set(iv, temp.instance_variable_get(iv))
            end
          else
            raise ::TypeError, "Bad Marshal data"
          end
        end

        # Psych support

        def encode_with(coder) # :nodoc:
          coder["wkt"] = to_wkt
        end

        def init_with(coder) # :nodoc:
          temp = CS.create_from_wkt(coder.type == :scalar ? coder.scalar : coder["wkt"])
          if temp.class == self.class
            temp.instance_variables.each do |iv|
              instance_variable_set(iv, temp.instance_variable_get(iv))
            end
          else
            raise ::TypeError, "Bad YAML data"
          end
        end

        class << self
          private :new
        end
      end

      # == OGC spec description
      #
      # Details of axis. This is used to label axes, and indicate the
      # orientation.

      class AxisInfo < Base
        # :stopdoc:
        NAMES_BY_VALUE = %w(OTHER NORTH SOUTH EAST WEST UP DOWN)
        # :startdoc:

        def initialize(name, orientation) # :nodoc:
          @name = name
          case orientation
          when ::String, ::Symbol
            @orientation = NAMES_BY_VALUE.index(orientation.to_s.upcase).to_i
          else
            @orientation = orientation.to_i
          end
        end

        # Human readable name for axis. Possible values are "X", "Y",
        # "Long", "Lat" or any other short string.
        attr_reader :name

        # Gets enumerated value for orientation.
        attr_reader :orientation

        def _wkt_typename # :nodoc:
          "AXIS"
        end

        def _wkt_content(open, close) # :nodoc:
          [NAMES_BY_VALUE[@orientation]]
        end

        class << self
          # Creates an AxisInfo. you must pass the human readable name for
          # the axis (e.g. "X", "Y", "Long", "Lat", or other short string)
          # and either an integer orientation code or a string. Possible
          # orientation values are "<tt>OTHER</tt>", "<tt>NORTH</tt>",
          # "<tt>SOUTH</tt>", "<tt>EAST</tt>", "<tt>WEST</tt>",
          # "<tt>UP</tt>", and "<tt>DOWN</tt>", or the corresponding
          # integer values 0-5.

          def create(name, orientation)
            new(name, orientation)
          end
        end
      end

      # == OGC spec description
      #
      # A named projection parameter value. The linear units of
      # parameters' values match the linear units of the containing
      # projected coordinate system. The angular units of parameter
      # values match the angular units of the geographic coordinate
      # system that the projected coordinate system is based on.

      class ProjectionParameter < Base
        def initialize(name, value) # :nodoc:
          @name = name
          @value = value.to_f
        end

        # The parameter name.
        attr_reader :name

        # The parameter value.
        attr_reader :value

        def _wkt_typename # :nodoc:
          "PARAMETER"
        end

        def _wkt_content(open, close) # :nodoc:
          [@value]
        end

        class << self
          # Create a parameter given the name and value.

          def create(name, value)
            new(name, value)
          end
        end
      end

      # == OGC spec description
      #
      # Parameters for a geographic transformation into WGS84. The Bursa
      # Wolf parameters should be applied to geocentric coordinates, where
      # the X axis points towards the Greenwich Prime Meridian, the Y axis
      # points East, and the Z axis points North.

      class WGS84ConversionInfo < Base
        def initialize(dx, dy, dz, ex, ey, ez, ppm) # :nodoc:
          @dx = dx.to_f
          @dy = dy.to_f
          @dz = dz.to_f
          @ex = ex.to_f
          @ey = ey.to_f
          @ez = ez.to_f
          @ppm = ppm.to_f
        end

        # Bursa Wolf shift in meters.
        attr_reader :dx

        # Bursa Wolf shift in meters.
        attr_reader :dy

        # Bursa Wolf shift in meters.
        attr_reader :dz

        # Bursa Wolf rotation in arc seconds.
        attr_reader :ex

        # Bursa Wolf rotation in arc seconds.
        attr_reader :ey

        # Bursa Wolf rotation in arc seconds.
        attr_reader :ez

        # Bursa Wolf scaling in in parts per million.
        attr_reader :ppm

        def _to_wkt(open, close) # :nodoc:
          "TOWGS84#{open}#{@dx},#{@dy},#{@dz},#{@ex},#{@ey},#{@ez},#{@ppm}#{close}"
        end

        class << self
          # Create the horizontal datum shift transformation into WGS84,
          # given the seven Bursa Wolf parameters.
          # The Bursa Wolf shift should be in meters, the rotation in arc
          # seconds, and the scaling in parts per million.

          def create(dx, dy, dz, ex, ey, ez, ppm)
            new(dx, dy, dz, ex, ey, ez, ppm)
          end
        end
      end

      # == OGC spec description
      #
      # A base interface for metadata applicable to coordinate system
      # objects.
      #
      # The metadata items "Abbreviation"’, "Alias", "Authority",
      # "AuthorityCode", "Name" and "Remarks" were specified in the Simple
      # Features interfaces, so they have been kept here.
      #
      # This specification does not dictate what the contents of these
      # items should be. However, the following guidelines are suggested:
      #
      # When CS_CoordinateSystemAuthorityFactory is used to create an
      # object, the "Authority" and "AuthorityCode" values should be set
      # to the authority name of the factory object, and the authority
      # code supplied by the client, respectively. The other values may or
      # may not be set. (If the authority is EPSG, the implementer may
      # consider using the corresponding metadata values in the EPSG
      # tables.)
      #
      # When CS_CoordinateSystemFactory creates an object, the "Name"
      # should be set to the value supplied by the client. All of the
      # other metadata items should be left empty.
      #
      # == Notes
      #
      # This is a non-instantiable abstract class.
      #
      # Most subclasses will have a set of optional parameters in their
      # "create" method to set the metadata fields. These parameters are,
      # in order:
      #
      # * <b>authority</b>: authority name
      # * <b>authority_code</b>: authority-specific identification code
      # * <b>abbreviation</b>: an abbreviation
      # * <b>alias</b>: an alias
      # * <b>remarks</b>: provider-supplied remarks.
      # * <b>extensions</b>: a hash of extension keys and values

      class Info < Base
        def initialize(name, authority = nil, authority_code = nil, abbreviation = nil, init_alias = nil, remarks = nil, extensions = nil) # :nodoc:
          @name = name
          @authority = authority ? authority.to_s : nil
          @authority_code = authority_code ? authority_code.to_s : nil
          @abbreviation = abbreviation ? abbreviation.to_s : nil
          @alias = init_alias ? init_alias.to_s : nil
          @remarks = remarks ? remarks.to_s : nil
          @extensions = {}
          if extensions
            extensions.each { |k, v| @extensions[k.to_s] = v.to_s }
          end
        end

        # Gets the abbreviation.
        attr_reader :abbreviation

        # Gets the alias.
        attr_reader :alias

        # Gets the authority name.
        # An Authority is an organization that maintains definitions of
        # Authority Codes. For example the European Petroleum Survey Group
        # (EPSG) maintains a database of coordinate systems, and other
        # spatial referencing objects, where each object has a code number
        # ID. For example, the EPSG code for a WGS84 Lat/Lon coordinate
        # system is "4326".
        attr_reader :authority

        # Gets the authority-specific identification code.
        # The AuthorityCode is a compact string defined by an Authority to
        # reference a particular spatial reference object. For example,
        # the European Survey Group (EPSG) authority uses 32 bit integers
        # to reference coordinate systems, so all their code strings will
        # consist of a few digits. The EPSG code for WGS84 Lat/Lon is
        # "4326".
        attr_reader :authority_code

        # Gets the name.
        attr_reader :name

        # Gets the provider-supplied remarks.
        attr_reader :remarks

        # Gets the value of a keyed extension.
        # This is not part of the OGC spec, but it is supported because
        # some coordinate system databases (such as the spatial_ref_sys
        # table for PostGIS 2.0) include it.
        def extension(key)
          @extensions[key.to_s]
        end
      end

      # == OGC spec description
      #
      # Base interface for defining units.
      #
      # == Notes
      #
      # Normally, you will instantiate one of the subclasses LinearUnit or
      # AngularUnit. However, it is possible to instantiate Unit if it is
      # not clear whether the data refers to a LinearUnit or AngularUnit.

      class Unit < Info
        def initialize(name, conversion_factor, *optional) # :nodoc:
          super(name, *optional)
          @conversion_factor = conversion_factor.to_f
        end

        # This field is not part of the OGC CT spec, but is part of the
        # SFS. It is an alias of the appropriate field in the subclass,
        # i.e. LinearUnit#meters_per_unit or AngularUnit#radians_per_unit.
        attr_reader :conversion_factor

        def _wkt_typename # :nodoc:
          "UNIT"
        end

        def _wkt_content(open, close) # :nodoc:
          [@conversion_factor]
        end

        class << self
          # Create a bare Unit that does not specify whether it is a
          # LinearUnit or an AngularUnit, given a unit name and a
          # conversion factor. You may also provide the optional
          # parameters specified by the Info interface.

          def create(name, conversion_factor, *optional)
            new(name, conversion_factor, *optional)
          end
        end
      end

      # == OGC spec description
      #
      # Definition of linear units.

      class LinearUnit < Unit
        # Returns the number of meters per LinearUnit.
        # Also available as Unit#conversion_factor.

        def meters_per_unit
          @conversion_factor
        end

        class << self
          # Create a LinearUnit given a unit name and a conversion factor
          # in meters per unit. You may also provide the optional
          # parameters specified by the Info interface.

          def create(name, meters_per_unit, *optional)
            new(name, meters_per_unit, *optional)
          end
        end
      end

      # == OGC spec description
      #
      # Definition of angular units.

      class AngularUnit < Unit
        # Returns the number of radians per AngularUnit.
        # Also available as Unit#conversion_factor.

        def radians_per_unit
          @conversion_factor
        end

        class << self
          # Create an AngularUnit given a unit name and a conversion
          # factor in radians per unit. You may also provide the optional
          # parameters specified by the Info interface.

          def create(name, radians_per_unit, *optional)
            new(name, radians_per_unit, *optional)
          end
        end
      end

      # == OGC spec description
      #
      # A meridian used to take longitude measurements from.

      class PrimeMeridian < Info
        def initialize(name, angular_unit, longitude, *optional) # :nodoc:
          super(name, *optional)
          @angular_unit = angular_unit
          @longitude = longitude.to_f
        end

        # Returns the AngularUnits.
        attr_reader :angular_unit

        # Returns the longitude value relative to the Greenwich Meridian.
        # The longitude is expressed in this objects angular units.
        attr_reader :longitude

        def _wkt_typename # :nodoc:
          "PRIMEM"
        end

        def _wkt_content(open, close) # :nodoc:
          [@longitude]
        end

        class << self
          # Create a PrimeMeridian given a name, AngularUnits, and the
          # longitude relative to the Greenwich Meridian, expressed in
          # the AngularUnits. You may also provide the optional parameters
          # specified by the Info interface.

          def create(name, angular_unit, longitude, *optional)
            new(name, angular_unit, longitude, *optional)
          end
        end
      end

      # == OGC spec description
      #
      # An approximation of the Earth's surface as a squashed sphere.

      class Ellipsoid < Info
        def initialize(name, semi_major_axis, semi_minor_axis, inverse_flattening, ivf_definitive, linear_unit, *optional) # :nodoc:
          super(name, *optional)
          @semi_major_axis = semi_major_axis.to_f
          @semi_minor_axis = semi_minor_axis.to_f
          @inverse_flattening = inverse_flattening.to_f
          @ivf_definitive = ivf_definitive ? true : false
          @linear_unit = linear_unit
        end

        # Gets the equatorial radius. The returned length is expressed in
        # this object's axis units.
        attr_reader :semi_major_axis

        # Gets the polar radius. The returned length is expressed in this
        # object's axis units.
        attr_reader :semi_minor_axis

        # Returns the value of the inverse of the flattening constant. The
        # inverse flattening is related to the equatorial/polar radius by
        # the formula ivf=re/(re-rp). For perfect spheres, this formula
        # breaks down, and a special IVF value of zero is used.
        attr_reader :inverse_flattening

        # Is the Inverse Flattening definitive for this ellipsoid? Some
        # ellipsoids use the IVF as the defining value, and calculate the
        # polar radius whenever asked. Other ellipsoids use the polar
        # radius to calculate the IVF whenever asked. This distinction can
        # be important to avoid floating-point rounding errors.
        attr_reader :ivf_definitive

        # Returns the LinearUnit. The units of the semi-major and
        # semi-minor axis values.
        attr_reader :axisunit

        def _wkt_typename # :nodoc:
          "SPHEROID"
        end

        def _wkt_content(open, close) # :nodoc:
          [@semi_major_axis, @inverse_flattening]
        end

        class << self
          # Create an Ellipsoid given a name, semi-major and semi-minor
          # axes, the inverse flattening, a boolean indicating whether
          # the inverse flattening is definitive, and the LinearUnit
          # indicating the axis units. The LinearUnit is optional and
          # may be set to nil. You may also provide the optional parameters
          # specified by the Info interface.

          def create(name, semi_major_axis, semi_minor_axis, inverse_flattening, ivf_definitive, linear_unit, *optional)
            new(name, semi_major_axis, semi_minor_axis, inverse_flattening, ivf_definitive, linear_unit, *optional)
          end

          # Create an Ellipsoid given a name, semi-major and semi-minor
          # axes, and the LinearUnit indicating the axis units. In the
          # resulting ellipsoid, the inverse flattening is not definitive.
          # The LinearUnit is optional and may be set to nil. You may also
          # provide the optional parameters specified by the Info interface.

          def create_ellipsoid(name, semi_major_axis, semi_minor_axis, linear_unit, *optional)
            semi_major_axis = semi_major_axis.to_f
            semi_minor_axis = semi_minor_axis.to_f
            inverse_flattening = semi_major_axis / (semi_major_axis - semi_minor_axis)
            inverse_flattening = 0.0 if inverse_flattening.infinite?
            new(name, semi_major_axis, semi_minor_axis, inverse_flattening, false, linear_unit, *optional)
          end

          # Create an Ellipsoid given a name, semi-major axis, inverse
          # flattening, and the LinearUnit indicating the axis units. In
          # the resulting ellipsoid, the inverse flattening is definitive.
          # The LinearUnit is optional and may be set to nil. You may also
          # provide the optional parameters specified by the Info interface.

          def create_flattened_sphere(name, semi_major_axis, inverse_flattening, linear_unit, *optional)
            semi_major_axis = semi_major_axis.to_f
            inverse_flattening = inverse_flattening.to_f
            semi_minor_axis = semi_major_axis - semi_major_axis / inverse_flattening
            semi_minor_axis = semi_major_axis if semi_minor_axis.infinite?
            new(name, semi_major_axis, semi_minor_axis, inverse_flattening, true, linear_unit, *optional)
          end
        end
      end

      # == OGC spec description
      #
      # A set of quantities from which other quantities are calculated.
      # For the OGC abstract model, it can be defined as a set of real
      # points on the earth that have coordinates. EG. A datum can be
      # thought of as a set of parameters defining completely the origin
      # and orientation of a coordinate system with respect to the earth.
      # A textual description and/or a set of parameters describing the
      # relationship of a coordinate system to some predefined physical
      # locations (such as center of mass) and physical directions (such
      # as axis of spin). The definition of the datum may also include
      # the temporal behavior (such as the rate of change of the
      # orientation of the coordinate axes).
      #
      # == Notes
      #
      # This is a non-instantiable abstract class. You must instantiate
      # one of the subclasses HorizontalDatum, VerticalDatum, or
      # LocalDatum.

      class Datum < Info
        def initialize(name, datum_type, *optional) # :nodoc:
          super(name, *optional)
          @datum_type = datum_type.to_i
        end

        # Gets the type of the datum as an enumerated code.
        attr_reader :datum_type

        def _wkt_content(open, close) # :nodoc:
          []
        end
      end

      # == OGC spec description
      #
      # Procedure used to measure vertical distances.

      class VerticalDatum < Datum
        def _wkt_typename # :nodoc:
          "VERT_DATUM"
        end

        def _wkt_content(open, close) # :nodoc:
          [@datum_type]
        end

        class << self
          # Create a VerticalDatum given a name and a datum type code.
          # You may also provide the optional parameters specified by the
          # Info interface.

          def create(name, datum_type, *optional)
            new(name, datum_type, *optional)
          end
        end
      end

      # == OGC spec description
      #
      # Local datum. If two local datum objects have the same datum type
      # and name, then they can be considered equal. This means that
      # coordinates can be transformed between two different local
      # coordinate systems, as long as they are based on the same local
      # datum.

      class LocalDatum < Datum
        def _wkt_typename # :nodoc:
          "LOCAL_DATUM"
        end

        def _wkt_content(open, close) # :nodoc:
          [@datum_type]
        end

        class << self
          # Create a LocalDatum given a name and a datum type code. You
          # may also provide the optional parameters specified by the
          # Info interface.

          def create(name, datum_type, *optional)
            new(name, datum_type, *optional)
          end
        end
      end

      # == OGC spec description
      #
      # Procedure used to measure positions on the surface of the Earth.

      class HorizontalDatum < Datum
        def initialize(name, datum_type, ellipsoid, wgs84_parameters, *optional) # :nodoc:
          super(name, datum_type, *optional)
          @ellipsoid = ellipsoid
          @wgs84_parameters = wgs84_parameters
        end

        # Returns the Ellipsoid.
        attr_reader :ellipsoid

        # Gets preferred parameters for a Bursa Wolf transformation into
        # WGS84. The 7 returned values correspond to (dx,dy,dz) in meters,
        # (ex,ey,ez) in arc-seconds, and scaling in parts-per-million.
        attr_reader :wgs84_parameters

        def _wkt_typename # :nodoc:
          "DATUM"
        end

        def _wkt_content(open, close) # :nodoc:
          array = [@ellipsoid._to_wkt(open, close)]
          array << @wgs84_parameters._to_wkt(open, close) if @wgs84_parameters
          array
        end

        class << self
          # Create a HorizontalDatum given a name, datum type code,
          # Ellipsoid, and WGS84ConversionInfo. The WGS84ConversionInfo
          # is optional and may be set to nil. You may also provide the
          # optional parameters specified by the Info interface.

          def create(name, datum_type, ellipsoid, wgs84_parameters, *optional)
            new(name, datum_type, ellipsoid, wgs84_parameters, *optional)
          end
        end
      end

      # == OGC spec description
      #
      # A projection from geographic coordinates to projected coordinates.

      class Projection < Info
        def initialize(name, class_name, parameters, *optional) # :nodoc:
          super(name, *optional)
          @class_name = class_name.to_s
          @parameters = parameters ? parameters.dup : []
        end

        # Gets the projection classification name
        # (e.g. "Transverse_Mercator").
        attr_reader :class_name

        # Gets number of parameters of the projection.

        def num_parameters
          @parameters.size
        end

        # Gets an inexed parameter of the projection.

        def get_parameter(index)
          @parameters[index]
        end

        # Iterates over the parameters of the projection.

        def each_parameter(&block)
          @parameters.each(&block)
        end

        def _wkt_typename # :nodoc:
          "PROJECTION"
        end

        def _wkt_content(open, close) # :nodoc:
          []
        end

        class << self
          # Create a Projection given a name, a projection class, and an
          # array of ProjectionParameter. You may also provide the
          # optional parameters specified by the Info interface.

          def create(name, class_name, parameters, *optional)
            new(name, class_name, parameters, *optional)
          end
        end
      end

      # == OGC spec description
      #
      # Base interface for all coordinate systems.
      #
      # A coordinate system is a mathematical space, where the elements
      # of the space are called positions. Each position is described by
      # a list of numbers. The length of the list corresponds to the
      # dimension of the coordinate system. So in a 2D coordinate system
      # each position is described by a list containing 2 numbers.
      #
      # However, in a coordinate system, not all lists of numbers
      # correspond to a position -- some lists may be outside the domain
      # of the coordinate system. For example, in a 2D Lat/Lon coordinate
      # system, the list (91,91) does not correspond to a position.
      #
      # Some coordinate systems also have a mapping from the mathematical
      # space into locations in the real world. So in a Lat/Lon coordinate
      # system, the mathematical position (lat, long) corresponds to a
      # location on the surface of the Earth. This mapping from the
      # mathematical space into real-world locations is called a Datum.
      #
      # == Notes
      #
      # This is a non-instantiable abstract class. You must instantiate
      # one of the subclasses GeocentricCoordinateSystem,
      # GeographicCoordinateSystem, ProjectedCoordinateSystem,
      # VerticalCoordinateSystem, LocalCoordinateSystem, or
      # CompoundCoordinateSystem.

      class CoordinateSystem < Info
        def initialize(name, dimension, *optional) # :nodoc:
          super(name, *optional)
          @dimension = dimension.to_i
        end

        # Dimension of the coordinate system
        attr_reader :dimension

        # Gets axis details for dimension within coordinate system. Each
        # dimension in the coordinate system has a corresponding axis.

        def get_axis(dimension)
          nil
        end

        # Gets units for dimension within coordinate system. Each
        # dimension in the coordinate system has corresponding units.

        def get_units(dimension)
          nil
        end
      end

      # == OGC spec description
      #
      # An aggregate of two coordinate systems (CRS). One of these is
      # usually a CRS based on a two dimensional coordinate system such
      # as a geographic or a projected coordinate system with a horizontal
      # datum. The other is a vertical CRS which is a one-dimensional
      # coordinate system with a vertical datum.

      class CompoundCoordinateSystem < CoordinateSystem
        def initialize(name, head, tail, *optional) # :nodoc:
          super(name, head.dimension + tail.dimension, *optional)
          @head = head
          @tail = tail
        end

        # Gets first sub-coordinate system.
        attr_reader :head

        # Gets second sub-coordinate system.
        attr_reader :tail

        # Implements CoordinateSystem#get_axis

        def get_axis(index)
          hd = @head.dimension
          index < hd ? @head.get_axis(index) : @tail.get_axis(index - hd)
        end

        # Implements CoordinateSystem#get_units

        def get_units(index)
          hd = @head.dimension
          index < hd ? @head.get_units(index) : @tail.get_units(index - hd)
        end

        def _wkt_typename # :nodoc:
          "COMPD_CS"
        end

        def _wkt_content(open, close) # :nodoc:
          [@head._to_wkt(open, close), @tail._to_wkt(open, close)]
        end

        class << self
          # Create a CompoundCoordinateSystem given two sub-coordinate
          # systems. You may also provide the optional parameters
          # specified by the Info interface.

          def create(name, head, tail, *optional)
            new(name, head, tail, *optional)
          end
        end
      end

      # == OGC spec description
      #
      # A local coordinate system, with uncertain relationship to the
      # world. In general, a local coordinate system cannot be related to
      # other coordinate systems. However, if two objects supporting this
      # interface have the same dimension, axes, units and datum then
      # client code is permitted to assume that the two coordinate systems
      # are identical. This allows several datasets from a common source
      # (e.g. a CAD system) to be overlaid. In addition, some
      # implementations of the Coordinate Transformation (CT) package may
      # have a mechanism for correlating local datums. (E.g. from a
      # database of transformations, which is created and maintained from
      # real-world measurements.)
      #
      # == Notes
      #
      # RGeo's implementation does not provide the Coordinate
      # Transformation (CT) package.

      class LocalCoordinateSystem < CoordinateSystem
        def initialize(name, local_datum, unit, axes, *optional) # :nodoc:
          super(name, axes.size, *optional)
          @local_datum = local_datum
          @unit = unit
          @axes = axes.dup
        end

        # Gets the local datum.
        attr_reader :local_datum

        # Implements CoordinateSystem#get_axis

        def get_axis(index)
          @axes[index]
        end

        # Implements CoordinateSystem#get_units

        def get_units(index)
          @unit
        end

        def _wkt_typename # :nodoc:
          "LOCAL_CS"
        end

        def _wkt_content(open, close) # :nodoc:
          [@local_datum._to_wkt(open, close), @unit._to_wkt(open, close)] + @axes.map { |ax| ax._to_wkt(open, close) }
        end

        class << self
          # Create a LocalCoordinateSystem given a name, a LocalDatum, a
          # Unit, and an array of at least one AxisInfo. You may also
          # provide the optional parameters specified by the Info
          # interface.

          def create(name, local_datum, unit, axes, *optional)
            new(name, local_datum, unit, axes, *optional)
          end
        end
      end

      # == OGC spec description
      #
      # A 3D coordinate system, with its origin at the centre of the
      # Earth. The X axis points towards the prime meridian. The Y axis
      # points East or West. The Z axis points North or South. By default
      # the Z axis will point North, and the Y axis will point East (e.g.
      # a right handed system), but you should check the axes for
      # non-default values.

      class GeocentricCoordinateSystem < CoordinateSystem
        def initialize(name, horizontal_datum, prime_meridian, linear_unit, axis0, axis1, axis2, *optional) # :nodoc:
          super(name, 3, *optional)
          @horizontal_datum = horizontal_datum
          @prime_meridian = prime_meridian
          @linear_unit = linear_unit
          @axis0 = axis0
          @axis1 = axis1
          @axis2 = axis2
        end

        # Returns the HorizontalDatum. The horizontal datum is used to
        # determine where the centre of the Earth is considered to be.
        # All coordinate points will be measured from the centre of the
        # Earth, and not the surface.
        attr_reader :horizontal_datum

        # Returns the PrimeMeridian.
        attr_reader :prime_meridian

        # Gets the units used along all the axes.
        attr_reader :linear_unit

        # Implements CoordinateSystem#get_units

        def get_units(index)
          @linear_unit
        end

        # Implements CoordinateSystem#get_axis

        def get_axis(index)
          [@axis0, @axis1, @axis2][index]
        end

        def _wkt_typename # :nodoc:
          "GEOCCS"
        end

        def _wkt_content(open, close) # :nodoc:
          arr = [@horizontal_datum._to_wkt(open, close), @prime_meridian._to_wkt(open, close), @linear_unit._to_wkt(open, close)]
          arr << @axis0._to_wkt(open, close) if @axis0
          arr << @axis1._to_wkt(open, close) if @axis1
          arr << @axis2._to_wkt(open, close) if @axis2
          arr
        end

        class << self
          # Create a GeocentricCoordinateSystem given a name, a
          # HorizontalDatum, a PrimeMeridian, a LinearUnit, and three
          # AxisInfo objects. The AxisInfo are optional and may be nil.
          # You may also provide the optional parameters specified by the
          # Info interface.

          def create(name, horizontal_datum, prime_meridian, linear_unit, axis0, axis1, axis2, *optional)
            new(name, horizontal_datum, prime_meridian, linear_unit, axis0, axis1, axis2, *optional)
          end
        end
      end

      # == OGC spec description
      #
      # A one-dimensional coordinate system suitable for vertical
      # measurements.

      class VerticalCoordinateSystem < CoordinateSystem
        def initialize(name, vertical_datum, vertical_unit, axis, *optional) # :nodoc:
          super(name, 1, *optional)
          @vertical_datum = vertical_datum
          @vertical_unit = vertical_unit
          @axis = axis
        end

        # Gets the vertical datum, which indicates the measurement method.
        attr_reader :vertical_datum

        # Gets the units used along the vertical axis. The vertical units
        # must be the same as the CS_CoordinateSystem units.
        attr_reader :vertical_unit

        # Implements CoordinateSystem#get_units

        def get_units(index)
          @vertical_unit
        end

        # Implements CoordinateSystem#get_axis

        def get_axis(index)
          @axis
        end

        def _wkt_typename # :nodoc:
          "VERT_CS"
        end

        def _wkt_content(open, close) # :nodoc:
          arr = [@vertical_datum._to_wkt(open, close), @vertical_unit._to_wkt(open, close)]
          arr << @axis._to_wkt(open, close) if @axis
          arr
        end

        class << self
          # Create a VerticalCoordinateSystem given a name, a
          # VerticalDatum, a LinearUnit, and an AxisInfo. The AxisInfo is
          # optional and may be nil. You may also provide the optional
          # parameters specified by the Info interface.

          def create(name, vertical_datum, vertical_unit, axis, *optional)
            new(name, vertical_datum, vertical_unit, axis, *optional)
          end
        end
      end

      # == OGC spec description
      #
      # A 2D coordinate system suitable for positions on the Earth's surface.
      #
      # == Notes
      #
      # This is a non-instantiable abstract class. You must instantiate
      # one of the subclasses GeographicCoordinateSystem or
      # ProjectedCoordinateSystem.

      class HorizontalCoordinateSystem < CoordinateSystem
        def initialize(name, horizontal_datum, *optional) # :nodoc:
          super(name, 2, *optional)
          @horizontal_datum = horizontal_datum
        end

        # Returns the HorizontalDatum.
        attr_reader :horizontal_datum
      end

      # == OGC spec description
      #
      # A coordinate system based on latitude and longitude. Some
      # geographic coordinate systems are Lat/Lon, and some are Lon/Lat.
      # You can find out which this is by examining the axes. You should
      # also check the angular units, since not all geographic coordinate
      # systems use degrees.

      class GeographicCoordinateSystem < HorizontalCoordinateSystem
        def initialize(name, angular_unit, horizontal_datum, prime_meridian, axis0, axis1, *optional) # :nodoc:
          super(name, horizontal_datum, *optional)
          @prime_meridian = prime_meridian
          @angular_unit = angular_unit
          @axis0 = axis0
          @axis1 = axis1
        end

        # Returns the PrimeMeridian.
        attr_reader :prime_meridian

        # Returns the AngularUnit. The angular unit must be the same as
        # the CS_CoordinateSystem units.
        attr_reader :angular_unit

        # Implements CoordinateSystem#get_units

        def get_units(index)
          @angular_unit
        end

        # Implements CoordinateSystem#get_axis

        def get_axis(index)
          index == 1 ? @axis1 : @axis0
        end

        # Gets the number of available conversions to WGS84 coordinates.

        def num_conversion_to_wgs84
          @horizontal_datum.wgs84_parameters ? 1 : 0
        end

        # Gets details on a conversion to WGS84. Some geographic
        # coordinate systems provide several transformations into WGS84,
        # which are designed to provide good accuracy in different areas
        # of interest. The first conversion (with index=0) should provide
        # acceptable accuracy over the largest possible area of interest.

        def get_wgs84_conversion_info(index)
          @horizontal_datum.wgs84_parameters
        end

        def _wkt_typename # :nodoc:
          "GEOGCS"
        end

        def _wkt_content(open, close) # :nodoc:
          arr = [@horizontal_datum._to_wkt(open, close), @prime_meridian._to_wkt(open, close), @angular_unit._to_wkt(open, close)]
          arr << @axis0._to_wkt(open, close) if @axis0
          arr << @axis1._to_wkt(open, close) if @axis1
          arr
        end

        class << self
          # Create a GeographicCoordinateSystem, given a name, an
          # AngularUnit, a HorizontalDatum, a PrimeMeridian, and two
          # AxisInfo objects. The AxisInfo objects are optional and may
          # be set to nil. You may also provide the optional parameters
          # specified by the Info interface.

          def create(name, angular_unit, horizontal_datum, prime_meridian, axis0, axis1, *optional)
            new(name, angular_unit, horizontal_datum, prime_meridian, axis0, axis1, *optional)
          end
        end
      end

      # == OGC spec description
      #
      # A 2D cartographic coordinate system.

      class ProjectedCoordinateSystem < HorizontalCoordinateSystem
        def initialize(name, geographic_coordinate_system, projection, linear_unit, axis0, axis1, *optional) # :nodoc:
          super(name, geographic_coordinate_system.horizontal_datum, *optional)
          @geographic_coordinate_system = geographic_coordinate_system
          @projection = projection
          @linear_unit = linear_unit
          @axis0 = axis0
          @axis1 = axis1
        end

        # Returns the GeographicCoordinateSystem.
        attr_reader :geographic_coordinate_system

        # Gets the projection.
        attr_reader :projection

        # Returns the LinearUnits. The linear unit must be the same as
        # the CS_CoordinateSystem units.
        attr_reader :linear_unit

        # Implements CoordinateSystem#get_units

        def get_units(index)
          @linear_unit
        end

        # Implements CoordinateSystem#get_axis

        def get_axis(index)
          index == 1 ? @axis1 : @axis0
        end

        def _wkt_typename # :nodoc:
          "PROJCS"
        end

        def _wkt_content(open, close) # :nodoc:
          arr = [@geographic_coordinate_system._to_wkt(open, close), @projection._to_wkt(open, close)]
          @projection.each_parameter { |param_| arr << param_._to_wkt(open, close) }
          arr << @linear_unit._to_wkt(open, close)
          arr << @axis0._to_wkt(open, close) if @axis0
          arr << @axis1._to_wkt(open, close) if @axis1
          arr
        end

        class << self
          # Create a ProjectedCoordinateSystem given a name, a
          # GeographicCoordinateSystem, and Projection, a LinearUnit, and
          # two AxisInfo objects. The AxisInfo objects are optional and
          # may be set to nil. You may also provide the optional
          # parameters specified by the Info interface.

          def create(name, geographic_coordinate_system, projection, linear_unit, axis0, axis1, *optional)
            new(name, geographic_coordinate_system, projection, linear_unit, axis0, axis1, *optional)
          end
        end
      end
    end
  end
end
