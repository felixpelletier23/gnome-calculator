#include <string.h>

#include "unit-manager.h"

typedef struct
{
    gchar *name;
    MPNumber value;
} Unit;

typedef struct
{
    gchar *name;
    GList *units;
} UnitCategory;

struct UnitManagerPrivate
{
    GList *categories;
};

G_DEFINE_TYPE (UnitManager, unit_manager, G_TYPE_OBJECT);


static UnitManager *default_unit_manager = NULL;


UnitManager *
unit_manager_new()
{
    return g_object_new(unit_manager_get_type(), NULL);
}


static void
add_category(UnitManager *manager, const gchar *name, const gchar *units[][2])
{
    int i;

    for (i = 0; units[i][0]; i++) {
        MPNumber r;
        mp_set_from_string(units[i][1], 10, &r);
        unit_manager_add(manager, name, units[i][0], &r);
    }
}


UnitManager *
unit_manager_get_default()
{
    const char *angle_units[][2] = {
        /* FIXME: Approximations of 1/(units in a circle)
         * Therefore, 360 deg != 400 grads */
        {"grad",     "0.0025"},
        {"gradian",  "0.0025"},
        {"gradians", "0.0025"},
        {"deg",      "0.002777778"},
        {"degree",   "0.002777778"},
        {"degrees",  "0.002777778"},
        {"rad",      "0.159154943"},
        {"radian",   "0.159154943"},
        {"radians",  "0.159154943"},
        {NULL, NULL}
    };

    const char *length_units[][2] = {
        {"parsec",     "30857000000000000"},
        {"parsecs",    "30857000000000000"},
        {"pc",         "30857000000000000"},
        {"lightyear",   "9460730472580800"},
        {"lightyears",  "9460730472580800"},
        {"ly",          "9460730472580800"},
        {"au",              "149597870691"},
        {"nm",                   "1852000"},
        {"mile",                    "1609.344"},
        {"miles",                   "1609.344"},
        {"mi",                      "1609.344"},
        {"kilometer",               "1000"},
        {"kilometers",              "1000"},
        {"km",                      "1000"},
        {"kms",                     "1000"},
        {"cable",                    "219.456"},
        {"cables",                   "219.456"},
        {"cb",                       "219.456"},
        {"fathom",                     "1.8288"},
        {"fathoms",                    "1.8288"},
        {"ftm",                        "1.8288"},
        {"meter",                      "1"},
        {"meters",                     "1"},
        {"m",                          "1"},
        {"yard",                       "0.9144"},
        {"yards",                      "0.9144"},
        {"yd",                         "0.9144"},
        {"foot",                       "0.3048"},
        {"feet",                       "0.3048"},
        {"ft",                         "0.3048"},
        {"inch",                       "0.0254"},
        {"inches",                     "0.0254"},
        {"centimeter",                 "0.01"},
        {"centimeters",                "0.01"},
        {"cm",                         "0.01"},
        {"cms",                        "0.01"},
        {"millimeter",                 "0.001"},
        {"millimeters",                "0.001"},
        {"mm",                         "0.001"},
        {"micrometer",                 "0.000001"},
        {"micrometers",                "0.000001"},
        {"um",                         "0.000001"},
        {"nanometer",                  "0.000000001"},
        {"nanometers",                 "0.000000001"},
        {NULL, NULL}
    };

    const char *area_units[][2] = {
        {"hectare",         "10000"},
        {"hectares",        "10000"},
        {"acre",             "4046.8564224"},
        {"acres",            "4046.8564224"},
        {"m²",                  "1"},
        {"cm²",                 "0.001"},
        {"mm²",                 "0.000001"},
        {NULL, NULL}
    };

    const char *volume_units[][2] = {
        {"m³",               "1000"},
        {"gallon",              "3.785412"},
        {"gallons",             "3.785412"},
        {"gal",                 "3.785412"},
        {"litre",               "1"},
        {"litres",              "1"},
        {"liter",               "1"},
        {"liters",              "1"},
        {"L",                   "1"},
        {"quart",               "0.9463529"},
        {"quarts",              "0.9463529"},
        {"qt",                  "0.9463529"},
        {"pint",                "0.4731765"},
        {"pints",               "0.4731765"},
        {"pt",                  "0.4731765"},
        {"millilitre",          "0.001"},
        {"millilitres",         "0.001"},
        {"milliliter",          "0.001"},
        {"milliliters",         "0.001"},
        {"mL",                  "0.001"},
        {"cm³",                 "0.001"},
        {"mm³",                 "0.000001"},
        {NULL, NULL}
    };

    const char *weight_units[][2] = {
        {"tonne",            "1000"},
        {"tonnes",           "1000"},
        {"kilograms",           "1"},
        {"kilogramme",          "1"},
        {"kilogrammes",         "1"},
        {"kg",                  "1"},
        {"kgs",                 "1"},
        {"pound",               "0.45359237"},
        {"pounds",              "0.45359237"},
        {"lb",                  "0.45359237"},
        {"ounce",               "0.02834952"},
        {"ounces",              "0.02834952"},
        {"oz",                  "0.02834952"},
        {"gram",                "0.001"},
        {"grams",               "0.001"},
        {"gramme",              "0.001"},
        {"grammes",             "0.001"},
        {"g",                   "0.001"},
        {NULL, NULL}
    };

    const char *time_units[][2] = {
        {"year",         "31557600"},
        {"years",        "31557600"},
        {"day",             "86400"},
        {"days",            "86400"},
        {"hour",             "3600"},
        {"hours",            "3600"},
        {"minute",             "60"},
        {"minutes",            "60"},
        {"second",              "1"},
        {"seconds",             "1"},
        {"s",                   "1"},
        {"millisecond",         "0.001"},
        {"milliseconds",        "0.001"},
        {"ms",                  "0.001"},
        {"microsecond",         "0.000001"},
        {"microseconds",        "0.000001"},
        {"us",                  "0.000001"},
        {NULL, NULL}
    };

    if (default_unit_manager)
        return default_unit_manager;
  
    default_unit_manager = unit_manager_new();
    add_category(default_unit_manager, "angles", angle_units);
    add_category(default_unit_manager, "length", length_units);
    add_category(default_unit_manager, "area", area_units);
    add_category(default_unit_manager, "volume", volume_units);
    add_category(default_unit_manager, "weight", weight_units);
    add_category(default_unit_manager, "time", time_units);

    return default_unit_manager;
}


static UnitCategory *
category_new(const gchar *name)
{
    UnitCategory *category;  
    category = g_malloc0(sizeof(UnitCategory));
    category->name = g_strdup(name);
    return category;
}


static UnitCategory *
get_category(UnitManager *manager, const gchar *category)
{
    GList *iter;

    for (iter = manager->priv->categories; iter; iter = iter->next) {
        UnitCategory *c = iter->data;
        if (strcmp(c->name, category) == 0)
            return c;
    }

    return NULL;
}


void
unit_manager_add(UnitManager *manager, const gchar *category, const gchar *name, MPNumber *value)
{
    UnitCategory *c;
    Unit *unit;

    c = get_category(manager, category);
    if (!c) {
        c = category_new(category);
        manager->priv->categories = g_list_append(manager->priv->categories, c);
    }

    unit = g_malloc0(sizeof(Unit));
    unit->name = g_strdup(name);
    mp_set_from_mp(value, &unit->value);
    c->units = g_list_append(c->units, unit);
}


static Unit *
get_unit(UnitCategory *category, const gchar *name)
{
    GList *iter;

    for (iter = category->units; iter; iter = iter->next) {
        Unit *unit = iter->data;
        if (strcmp(unit->name, name) == 0)
            return unit;
    }

    return NULL;
}


gboolean
unit_manager_convert(UnitManager *manager, const MPNumber *x, const char *x_units, const char *z_units, MPNumber *z)
{
    GList *iter;

    for (iter = manager->priv->categories; iter; iter = iter->next) {
        UnitCategory *c = iter->data;
        Unit *unit_x, *unit_z;
        if ((unit_x = get_unit(c, x_units)) && (unit_z = get_unit(c, z_units))) {
            mp_multiply(x, &unit_x->value, z);
            mp_divide(z, &unit_z->value, z);
            return TRUE;
        }
    }
  
    return FALSE;
}


static void
unit_manager_class_init(UnitManagerClass *klass)
{
    g_type_class_add_private(klass, sizeof(UnitManagerPrivate));
}


static void
unit_manager_init(UnitManager *manager)
{
    manager->priv = G_TYPE_INSTANCE_GET_PRIVATE(manager, unit_manager_get_type(), UnitManagerPrivate);
}