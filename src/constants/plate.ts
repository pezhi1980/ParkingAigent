/**
 * Danish license plate physical dimensions.
 * Standard DK plate: 520mm × 110mm
 * Used as the reference object for distance calculation via focal-length formula.
 * Source: Bekendtgørelse om nummerplader (BEK nr 1352 af 27/11/2017)
 */
export const DANISH_PLATE = {
  /** Physical width of a standard Danish license plate in millimeters */
  WIDTH_MM: 520,
  /** Physical height of a standard Danish license plate in millimeters */
  HEIGHT_MM: 110,
} as const;
